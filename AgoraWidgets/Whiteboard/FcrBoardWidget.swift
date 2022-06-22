//
//  FcrBoardWidget.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import Armin
import Photos

struct FcrBoardInitCondition {
    var configComplete = false
    var needJoin = false
}

@objcMembers public class FcrBoardWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    
    var logger: AgoraWidgetLogger
    
    private var dt: FcrBoardWidgetDT
    private var boardRoom: FcrBoardRoom?
    private var mainWindow: FcrBoardMainWindow?

    var initCondition = FcrBoardInitCondition() {
        didSet {
            if initCondition.configComplete,
               initCondition.needJoin {
                joinWhiteboard()
            }
        }
    }
    
    private var serverAPI: FcrWhiteBoardServerAPI?
    
    override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId,
                                       logId: widgetInfo.localUserInfo.userUuid)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        self.dt = FcrBoardWidgetDT(localUserInfo: widgetInfo.localUserInfo,
                                   roomName: widgetInfo.roomInfo.roomName)
        
        super.init(widgetInfo: widgetInfo)
        
        self.dt.delegate = self
    }
    
    public override func onLoad() {
        super.onLoad()
        
        if let configExtra = info.roomProperties?.toObj(FcrBooardConfigOfExtra.self) {
            dt.configExtra = configExtra
        }
        if let usageExtra = info.roomProperties?.toObj(FcrBooardUsageOfExtra.self) {
            dt.grantedUsers = usageExtra.grantedUsers
        }
        log(content: "[FcrBoardWidget]: onLoad room properties",
            extra: info.roomProperties?.description,
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
        log(content: "[FcrBoardWidget]: onWidgetRoomPropertiesUpdated",
            extra: properties.description,
            type: .info)
        
        if let configExtra = properties.toObj(FcrBooardConfigOfExtra.self) {
            dt.configExtra = configExtra
        }
        if let usageExtra = properties.toObj(FcrBooardUsageOfExtra.self) {
            dt.grantedUsers = usageExtra.grantedUsers
        }
    }
    
    public override func onWidgetRoomPropertiesDeleted(_ properties: [String : Any]?,
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetRoomPropertiesDeleted(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        log(content: "[FcrBoardWidget]: onWidgetRoomPropertiesDeleted",
            extra: keyPaths.agDescription,
            type: .info)
        
        if let usageExtra = properties?.toObj(FcrBooardUsageOfExtra.self) {
            dt.grantedUsers = usageExtra.grantedUsers
        }
    }
    
    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        log(content: "[FcrBoardWidget]: onMessageReceived",
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
                self?.log(content: "[FcrBoardWidget]: updateRoomProperties successfully",
                          extra: granedtUsers.agDescription,
                          type: .info)
            } failure: { [weak self] (error) in
                self?.log(content: "[FcrBoardWidget]: updateRoomProperties error",
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
                self?.log(content: "[FcrBoardWidget]: deleteRoomProperties successfully",
                          extra: keyPaths.agDescription,
                          type: .info)
            } failure: { [weak self] (error) in
                self?.log(content: "[FcrBoardWidget]: deleteRoomProperties unsuccessfully",
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
            var addFlag = (count >= dt.page.count)
            let changeCount = abs(count - dt.page.count)
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
        switch PHPhotoLibrary.authorizationStatus() {
        case .restricted, .denied, .limited, .notDetermined:
            // 自定弹窗
            self.sendMessage(signal: .OnBoardSaveResult(.noAlbumAuth))
            return
        default:
            break
        }
        
        AgoraWidgetLoading.addLoading(in: view)
        mainWindow.getAllWindowsSnapshotImageList(combinedCount: 10,
                                                  imageFolder: dt.snapshotFolder) { [weak self] list in
            self?.saveImagesToPhotoLibrary(imagePathList: list)
        }
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
        
        serverAPI.getWindowAttributes { [weak self,weak mainWindow] (json) in
            guard let `self` = self,
                  let `mainWindow` = self.mainWindow else {
                return
            }
            
            mainWindow.setAttributes(json)
        } failure: { [weak self] error in
            self?.ifNeedSetWindowAttributes()
        }
    }
    
    func joinWhiteboard() {
        guard let config = dt.configExtra else {
            return
        }
        
        // init
        let boardRegion = FcrBoardRegion(rawValue: config.boardRegion) ?? .cn
        boardRoom = FcrBoardRoom(appId: config.boardAppId,
                                 region: boardRegion)
        
        view.superview?.layoutIfNeeded()
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        var ratio: CGFloat
        
        if width < 1 || height < 1 {
            ratio = (16.0 / 9.0)
        } else {
            ratio = height / width
        }
        
        let joinConfig = FcrBoardRoomJoinConfig(roomId: config.boardId,
                                                roomToken: config.boardToken,
                                                boardRatio: Float(ratio),
                                                hasOperationPrivilege: dt.hasOperationPrivilege,
                                                userId: info.localUserInfo.userUuid,
                                                userName: info.localUserInfo.userName)
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
        try? FileManager.default.removeItem(atPath: dt.currentSnapshotFolder)
        AgoraWidgetLoading.removeLoading(in: view)
        
        if let error = error {
          log(content: "[FcrBoardWidget]: didFinishSavingImage error",
              extra: error.description,
              type: .error)
        }

        log(content: "[FcrBoardWidget]: didFinishSavingImage",
            extra: dt.currentSnapshotFolder,
            type: .info)
        
        self.sendMessage(signal: .OnBoardSaveResult(.savedToAlbum))
      }
    
    func sendMessage(signal: FcrBoardInteractionSignal) {
        guard let text = signal.toMessageString() else {
            log(content: "[FcrBoardWidget]: signal encode error!",
                type: .error)
            return
        }
        sendMessage(text)
    }
    
    func setUpInitialState() {
        guard let `mainWindow` = mainWindow else {
            return
        }
        if dt.isLocalTeacher() {
            dt.hasOperationPrivilege = true
        }
        let page = mainWindow.getPageInfo()
        dt.page = (index: Int(page.showIndex),
                   count: Int(page.count))
        ifNeedSetWindowAttributes()
        
        if let usageExtra = info.roomProperties?.toObj(FcrBooardUsageOfExtra.self) {
            dt.grantedUsers = usageExtra.grantedUsers
        }
        
        sendMessage(signal: .BoardPageChanged(.count(dt.page.count)))
    }
}

// MARK: - FcrBoardMainWindowDelegate
extension FcrBoardWidget: FcrBoardMainWindowDelegate {
    func onPageInfoUpdated(info: FcrBoardPageInfo) {
        dt.page = (index: Int(info.showIndex),
                   count: Int(info.count))
    }
    
    func onUndoStateUpdated(enable: Bool) {
        sendMessage(signal: .BoardStepChanged(.undoAble(enable)))
    }
    
    func onRedoStateUpdated(enable: Bool) {
        sendMessage(signal: .BoardStepChanged(.redoAble(enable)))
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

// MARK: - FcrBoardWidgetDTDelegate
extension FcrBoardWidget: FcrBoardWidgetDTDelegate {
    func onConfigComplete() {
        initCondition.configComplete = true
    }
    
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool) {
        mainWindow?.updateOperationPrivilege(hasPrivilege: localGranted,
                                             success: { [weak self] in
            self?.log(info: "[FcrBoardWidget]: updateOperationPrivilege",
                      extra: "\(localGranted)")
        }, failure: { [weak self] error in
            self?.log(content: "[FcrBoardWidget]: updateOperationPrivilege unsuccessfully",
                      extra: "\(localGranted)",
                      type: .error)
        })
    }
    
    func onGrantedUsersChanged(grantedUsers: [String]) {
        sendMessage(signal: .GetBoardGrantedUsers(grantedUsers))
    }
    
    func onPageCountChanged(count: Int) {
        sendMessage(signal: .BoardPageChanged(.count(count)))
    }
    
    func onPageIndexChanged(index: Int) {
        sendMessage(signal: .BoardPageChanged(.index(index)))
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
