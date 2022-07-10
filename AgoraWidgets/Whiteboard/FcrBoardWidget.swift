//
//  FcrBoardWidget.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import AgoraLog
import Photos
import Armin

struct FcrBoardInitCondition {
    var configComplete = false
    var needJoin = false
}

@objcMembers public class FcrBoardWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    var logger: AgoraWidgetLogger
    
    private var boardRoom: FcrBoardRoom?
    private var mainWindow: FcrBoardMainWindow?

    private var initCondition = FcrBoardInitCondition() {
        didSet {
            guard initCondition.configComplete,
                  initCondition.needJoin
            else {
                return
            }
            joinWhiteboard()
        }
    }
    
    private var serverAPI: FcrWhiteBoardServerAPI?
    
    /**Data**/
    private var currentSnapshotFolder: String = ""
    private var snapshotFolder: String {
        get {
            let folderName = "\(info.roomInfo.roomName)_\(String.currentTimeString())"
            let folder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                             .userDomainMask,
                                                             true)[0].appendingPathComponent(folderName)
            currentSnapshotFolder = folder
            return folder
        }
    }
    
    private var imageCountToSave: Int = 0
    
    // 教师角色加入房间成功时设置，学生角色监听grantedUsers变化设置
    private var hasOperationPrivilege: Bool = false
    
    override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId,
                                       logId: widgetInfo.localUserInfo.userUuid)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
    }
    
    public override func onLoad() {
        super.onLoad()
        
        analyzeBoardConfigFromRoomProperties()
        
        let extra: [String: Any] = ["roomId": info.roomInfo.roomUuid,
                                    "roomType": info.roomInfo.roomType,
                                    "roomProperties": info.roomProperties?.description,
                                    "userProperties": info.localUserProperties?.description]
        
        log(content: "onLoad",
            extra: extra.description,
            type: .info)
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        log(content: "onWidgetRoomPropertiesUpdated",
            extra: properties.description,
            type: .info)
        
        analyzeBoardConfigFromRoomProperties()

        analyzeGrantedUsersFromRoomProperties()
    }
    
    public override func onWidgetRoomPropertiesDeleted(_ properties: [String : Any]?,
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetRoomPropertiesDeleted(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        log(content: "onWidgetRoomPropertiesDeleted",
            extra: keyPaths.agDescription,
            type: .info)
        
        analyzeGrantedUsersFromRoomProperties()
    }
    
    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        log(content: "onMessageReceived",
            extra: message,
            type: .info)
        
        if let keys = message.toRequestKeys() {
            initServerAPI(keys: keys)
            return
        }
        
        if let signal = message.toBoardWidgetSignal() {
            switch signal {
            case .JoinBoard:
                initCondition.needJoin = true
            case .ChangeAssistantType(let assistantType):
                handleChangeAssistantType(type: assistantType)
            case .AudioMixingStateChanged(let audioMixingData):
                handleAudioMixing(data: audioMixingData)
            case .UpdateGrantedUsers(let type):
                handleBoardGrant(type: type)
            case .BoardPageChanged(let changeType):
                handlePageChange(changeType: changeType)
            case .BoardStepChanged(let changeType):
                handleStepChange(changeType: changeType)
            case .ClearBoard:
                // 清屏，保留ppt
                mainWindow?.clean()
            case .OpenCourseware(let courseware):
                handleOpenCourseware(info: courseware)
            case .SaveBoard:
                handleSaveBoardImage()
            case .ChangeRatio:
                updateViewRatio()
            default:
                break
            }
        }
    }
}

private extension FcrBoardWidget {
    // MARK: - message handle
    func handleOpenCourseware(info: FcrBoardCoursewareInfo) {
        if let scenes = info.scenes {
            var resourceHasAnimation = false
            if let convert = info.convert,
            convert {
                resourceHasAnimation = true
            }
            let config = FcrBoardSubWindowConfig(resourceUuid: info.resourceUuid,
                                                 resourceHasAnimation: resourceHasAnimation,
                                                 title: info.resourceName,
                                                 pageList: scenes.toWrapper())
            mainWindow?.createSubWindow(config: config)
        } else {
            let mediaConfig = FcrBoardMediaSubWindowConfig(resourceUrl: info.resourceUrl,
                                                           title: info.resourceName)
            mainWindow?.createMediaSubWindow(config: mediaConfig)
        }
    }
    
    func handleChangeAssistantType(type: FcrBoardAssistantType) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        switch type {
        case .tool(let fcrBoardAidType):
            mainWindow.selectTool(type: fcrBoardAidType.wrapperType)
        case .text(let fcrBoardTextInfo):
            guard let fcrColor = fcrBoardTextInfo.color.wrapperType else {
                return
            }
            mainWindow.inputText(fontSize: UInt16(fcrBoardTextInfo.size),
                                 color: fcrColor)
        case .shape(let fcrBoardShapeInfo):
            guard let fcrColor = fcrBoardShapeInfo.color.wrapperType else {
                return
            }
            mainWindow.drawShape(type: fcrBoardShapeInfo.type.wrapperType,
                                 lineWidth: UInt16(fcrBoardShapeInfo.width),
                                 color: fcrColor)
        }
    }
    
    func handleAudioMixing(data: FcrBoardAudioMixingData) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        mainWindow.setMediaState(stateCode: data.stateCode,
                                 errorCode: data.errorCode)
    }
    
    func handleBoardGrant(type: FcrBoardGrantUsersChangeType) {
        let grantedUsersKey = "grantedUsers"
        
        switch type {
        case .add(let array):
            guard array.count > 0 else {
                return
            }
            var granedtUsers = [String: Bool]()
            for id in array {
                let key = "\(grantedUsersKey).\(id)"
                granedtUsers[key] = true
            }
            
            updateRoomProperties(granedtUsers,
                                 cause: nil) { [weak self] in
                self?.log(content: "updateRoomProperties successfully",
                          extra: granedtUsers.agDescription,
                          type: .info)
            } failure: { [weak self] (error) in
                self?.log(content: "updateRoomProperties error",
                          extra: granedtUsers.agDescription,
                          type: .error)
            }
        case .delete(let array):
            guard array.count > 0 else {
                return
            }
            var keyPaths = [String]()
            for id in array {
                keyPaths.append("\(grantedUsersKey).\(id)")
            }
            deleteRoomProperties(keyPaths,
                                 cause: nil) { [weak self] in
                self?.log(content: "deleteRoomProperties successfully",
                          extra: keyPaths.agDescription,
                          type: .info)
            } failure: { [weak self] (error) in
                self?.log(content: "deleteRoomProperties unsuccessfully",
                          extra: keyPaths.agDescription,
                          type: .error)
            }
        }
    }
    
    func handlePageChange(changeType: FcrBoardPageChangeType) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        switch changeType {
        case .index(let index):
            mainWindow.setPageIndex(index: UInt16(index < 0 ? 0 : index))
        case .count(let count):
            let pageCount = Int(mainWindow.getPageInfo().count)
            var addFlag = (count >= pageCount)
            let changeCount = abs(count - pageCount)
            for _ in (0 ..< changeCount) {
                if addFlag {
                    mainWindow.addPage()
                } else {
                    mainWindow.removePage()
                }
            }
            mainWindow.setPageIndex(index: UInt16(count - 1))
        }
    }
    
    func handleStepChange(changeType: FcrBoardStepChangeType) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        switch changeType {
        case .pre(let count):
            for _ in 0 ..< count {
                mainWindow.undo()
            }
        case .next(let count):
            for _ in 0 ..< count {
                mainWindow.redo()
            }
        default:
            break
        }
    }
    
    func handleSaveBoardImage() {
        guard let `mainWindow` = mainWindow else {
            return
        }
        
        // photo auth handle
        var photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        
        if #available(iOS 14, *) {
            photoAuthStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            // Fallback on earlier versions
            photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        }
        
        guard photoAuthStatus == .authorized else {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    guard status != .authorized else {
                        return
                    }
                    self.sendMessage(signal: .OnBoardSaveResult(.noAlbumAuth))
                }
            } else {
                // Fallback on earlier versions
                PHPhotoLibrary.requestAuthorization { status in
                    guard status != .authorized else {
                        return
                    }
                    self.sendMessage(signal: .OnBoardSaveResult(.noAlbumAuth))
                }
            }
            return
        }
        AgoraWidgetLoading.addLoading(in: view)
        mainWindow.getAllWindowsSnapshotImageList(combinedCount: 10,
                                                  imageFolder: snapshotFolder) { [weak self] list in
            self?.saveImagesToPhotoLibrary(imagePathList: list)
        }
    }
    
    func updateViewRatio() {
        guard let `mainWindow` = mainWindow else {
            return
        }
        let ratio = Float(view.ratio())
        mainWindow.setContainerSizeRatio(ratio: ratio)
    }

    // MARK: - private
    func initServerAPI(keys: AgoraWidgetRequestKeys) {
        serverAPI = FcrWhiteBoardServerAPI(host: keys.host,
                                             appId: keys.agoraAppId,
                                             token: keys.token,
                                             roomId: info.roomInfo.roomUuid,
                                             userId: info.localUserInfo.userUuid,
                                             logTube: self)
    }
    
    func ifNeedSetWindowAttributes() {
        guard let `serverAPI` = serverAPI,
              let userProperties = info.localUserProperties,
              let isNeedSet = userProperties["initial"] as? Bool,
              isNeedSet == true else {
            return
        }
        
        serverAPI.getWindowAttributes { [weak self] (json) in
            guard let `self` = self,
                  let `mainWindow` = self.mainWindow else {
                return
            }
            
            if mainWindow.hasOperationPrivilege == true {
                mainWindow.setAttributes(json)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.ifNeedSetWindowAttributes()
                }
            }
        } failure: { [weak self] error in
            self?.ifNeedSetWindowAttributes()
        }
    }
    
    func joinWhiteboard() {
        guard let config = info.roomProperties?.toObj(FcrBooardConfigOfExtra.self) else {
            return
        }
        
        // init
        let boardRegion = FcrBoardRegion(rawValue: config.boardRegion) ?? .cn
        boardRoom = FcrBoardRoom(appId: config.boardAppId,
                                 region: boardRegion)
        boardRoom?.delegate = self
        
        boardRoom?.logTube = self
        
        let ratio = view.ratio()
        
        let joinConfig = FcrBoardRoomJoinConfig(roomId: config.boardId,
                                                roomToken: config.boardToken,
                                                boardRatio: Float(ratio),
                                                hasOperationPrivilege: isLocalTeacher(),
                                                userId: info.localUserInfo.userUuid,
                                                userName: info.localUserInfo.userName)
        AgoraWidgetLoading.addLoading(in: view)
        boardRoom!.join(config: joinConfig,
                        superView: view) { [weak self] mainWindow in
            guard let `self` = self else {
                return
            }
            self.log(content: "[FcrBoardWidget]:join successfully",
                     extra: nil,
                     type: .info)
            self.mainWindow = mainWindow
            mainWindow.delegate = self
            mainWindow.logTube = self
            
            self.initCondition.needJoin = false
            
            self.setUpInitialState()
        } failure: { [weak self] error in
            guard let `self` = self else {
                return
            }
            self.log(content: "[FcrBoardWidget]:join unsuccessfully",
                      extra: error.localizedDescription,
                      type: .error)
        }
    }
    
    func saveImagesToPhotoLibrary(imagePathList: [String]) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.imageCountToSave = imagePathList.count
            for path in imagePathList {
                guard let image = UIImage(contentsOfFile: path) else {
                    continue
                }
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.didFinishSavingImage(image:error:contextInfo:)),
                                               nil)
            }
        }
    }
    
    @objc func didFinishSavingImage(image: UIImage,
                                    error: NSError?,
                                    contextInfo: UnsafeRawPointer?) {
        if let error = error {
          log(content: "save single image error",
              extra: error.description,
              type: .error)
        } else {
            log(content: "save single image successfully",
                extra: currentSnapshotFolder,
                type: .info)
        }
        imageCountToSave -= 1
        guard imageCountToSave == 0 else {
            return
        }

        try? FileManager.default.removeItem(atPath: currentSnapshotFolder)
        AgoraWidgetLoading.removeLoading(in: view)
        
        sendMessage(signal: .OnBoardSaveResult(.savedToAlbum))
      }
    
    func sendMessage(signal: FcrBoardInteractionSignal) {
        guard let text = signal.toMessageString() else {
            log(content: "signal encode error!",
                type: .error)
            return
        }
        sendMessage(text)
    }
    
    private func analyzeBoardConfigFromRoomProperties() {
        if let configExtra = info.roomProperties?.toObj(FcrBooardConfigOfExtra.self) {
            initCondition.configComplete = true
        }
    }
    
    private func analyzeGrantedUsersFromRoomProperties() {
        var grantedUsers = [String]()

        if let usageExtra = info.roomProperties?.toObj(FcrBooardUsageOfExtra.self) {
            grantedUsers = Array(usageExtra.grantedUsers.keys)
        }
        
        // 为保证逻辑，若本地为老师，将老师uuid加入grantedUsers中
        if isLocalTeacher(),
           !grantedUsers.contains(info.localUserInfo.userUuid) {
            grantedUsers.append(info.localUserInfo.userUuid)
        }
        
        var newLocalPrivilege = true
        if !isLocalTeacher(),
           !grantedUsers.contains(info.localUserInfo.userUuid) {
            newLocalPrivilege = false
        }
        
        var privilegeNeedChanged = (newLocalPrivilege != hasOperationPrivilege)
        
        guard privilegeNeedChanged else {
            sendMessage(signal: .GetBoardGrantedUsers(grantedUsers))
            return
        }
        
        mainWindow?.updateOperationPrivilege(hasPrivilege: newLocalPrivilege,
                                             success: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.log(info: "updateOperationPrivilege",
                     extra: "\(newLocalPrivilege)")
            
            self.hasOperationPrivilege = newLocalPrivilege
            self.sendMessage(signal: .GetBoardGrantedUsers(grantedUsers))
        }, failure: { [weak self] error in
            guard let `self` = self else {
                return
            }
            self.log(content: "updateOperationPrivilege unsuccessfully",
                     extra: "\(newLocalPrivilege)",
                     type: .error)
        })
    }
    
    func setUpInitialState() {
        guard let `mainWindow` = mainWindow else {
            return
        }
        if isLocalTeacher() {
            hasOperationPrivilege = true
        }
        
        ifNeedSetWindowAttributes()

        analyzeGrantedUsersFromRoomProperties()
        // 发送页数初始状态
        let basePageInfo = mainWindow.getPageInfo()
        let pageCount = Int(basePageInfo.count)
        let pageIndex = Int(basePageInfo.showIndex)
        sendMessage(signal: .BoardPageChanged(.count(pageCount)))
        sendMessage(signal: .BoardPageChanged(.index(pageIndex)))
    }
    
    func isLocalTeacher() -> Bool {
        return (info.localUserInfo.userRole == "teacher")
    }
}

// MARK: - FcrBoardRoomDelegate
extension FcrBoardWidget: FcrBoardRoomDelegate {
    func onConnectionStateUpdated(state: FcrBoardRoomConnectionState) {
        let extra = state.agDescription
        log(info: "onConnectionStateUpdated",
            extra: extra)
        
        switch state {
        case .connected:
            AgoraWidgetLoading.removeLoading(in: view)
        case .reconnecting:
            AgoraWidgetLoading.addLoading(in: view)
        case .disconnected:
            initCondition.needJoin = true
        default:
            break
        }
    }
}

// MARK: - FcrBoardMainWindowDelegate
extension FcrBoardWidget: FcrBoardMainWindowDelegate {
    func onPageInfoUpdated(info: FcrBoardPageInfo) {
        sendMessage(signal: .BoardPageChanged(.count(Int(info.count))))
        sendMessage(signal: .BoardPageChanged(.index(Int(info.showIndex))))
    }
    
    func onUndoStateUpdated(enable: Bool) {
        sendMessage(signal: .BoardStepChanged(.undoAble(enable)))
    }
    
    func onRedoStateUpdated(enable: Bool) {
        sendMessage(signal: .BoardStepChanged(.redoAble(enable)))
    }
    
    func onWindowBoxStateChanged(state: FcrWindowBoxState) {
        sendMessage(signal: .WindowStateChanged(state.toWidget))
    }
    
    func onStartAudioMixing(filePath: String,
                            loopback: Bool,
                            replace: Bool,
                            cycle: Int) {
        let request = FcrBoardAudioMixingRequestData(requestType: .start,
                                                     filePath: filePath,
                                                     loopback: loopback,
                                                     replace: replace,
                                                     cycle: cycle)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    func onStopAudioMixing() {
        let request = FcrBoardAudioMixingRequestData(requestType: .stop)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    func onAudioMixingPositionUpdated(position: Int) {
        let request = FcrBoardAudioMixingRequestData(requestType: .setPosition,
                                                     position: position)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
}

extension FcrBoardWidget: FcrBoardLogTube {
    func onBoardLog(content: String,
                    extra: String?,
                    type: FcrBoardLogType,
                    fromClass: AnyClass,
                    funcName: String,
                    line: Int) {
        log(content: content,
            extra: extra,
            type: type.toAgoraType,
            fromClass: fromClass,
            funcName: funcName,
            line: line)
    }
    
    func onNetlessLog(content: String,
                      extra: String?,
                      type: FcrBoardLogType) {
        log(content: content,
            extra: extra,
            type: type.toAgoraType)
    }
}

// MARK: - ArLogTube
extension FcrBoardWidget: ArLogTube {
    public func log(info: String,
                    extra: String?) {
        log(content: info,
            extra: extra,
            type: .info)
    }
    
    public func log(warning: String,
                    extra: String?) {
        log(content: warning,
            extra: extra,
            type: .info)
    }
    
    public func log(error: ArError,
                    extra: String?) {
        log(content: error.localizedDescription,
            extra: extra,
            type: .info)
    }
}

fileprivate extension String {
    static func currentTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: Date())
    }
}

fileprivate extension UIView {
    func ratio() -> CGFloat {
        superview?.layoutIfNeeded()
        
        let width = bounds.width
        let height = bounds.height
        
        var ratio: CGFloat
        
        if width < 1 || height < 1 {
            ratio = (16.0 / 9.0)
        } else {
            ratio = height / width
        }
        
        return ratio
    }
}

fileprivate extension FcrBoardLogType {
    var toAgoraType: AgoraLogType {
        switch self {
        case .info:     return .info
        case .warning:  return .warning
        case .error:    return .error
        }
    }
}
