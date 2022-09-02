//
//  FcrBoardWidget.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import AgoraUIBaseViews
import AgoraWidget
import AgoraLog
import Photos
import Armin

struct FcrBoardInitCondition {
    var configComplete = false
    var needJoin = false
}

@objcMembers public class FcrBoardWidget: AgoraNativeWidget {
    /**views**/
    private lazy var pageControl = FcrBoardPageControlView(frame: .zero)
    
    /**data**/
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
    
    private var serverAPI: FcrBoardServerAPI?
    
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
    private var hasOperationPrivilege: Bool = false {
        didSet {
            guard pageControl.agora_enable else {
                return
            }
            pageControl.agora_visible = hasOperationPrivilege
        }
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
            case .joinBoard:
                initCondition.needJoin = true
            case .changeAssistantType(let assistantType):
                handleChangeAssistantType(type: assistantType)
            case .audioMixingStateChanged(let audioMixingData):
                handleAudioMixing(data: audioMixingData)
            case .updateGrantedUsers(let type):
                handleBoardGrant(type: type)
            case .boardStepChanged(let changeType):
                handleStepChange(changeType: changeType)
            case .clearBoard:
                mainWindow?.clean()
            case .openCourseware(let courseware):
                handleOpenCourseware(info: courseware)
            case .saveBoard:
                handleSaveBoardImage()
            case .changeRatio:
                updateViewRatio()
            default:
                break
            }
        }
    }
}

// MARK: - private
private extension FcrBoardWidget {
    // MARK:  message handle
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
                    self.sendMessage(signal: .onBoardSaveResult(.noAlbumAuth))
                }
            } else {
                // Fallback on earlier versions
                PHPhotoLibrary.requestAuthorization { status in
                    guard status != .authorized else {
                        return
                    }
                    self.sendMessage(signal: .onBoardSaveResult(.noAlbumAuth))
                }
            }
            return
        }
        
        AgoraLoading.loading(in: view)
        
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

    // MARK: private
    func initServerAPI(keys: AgoraWidgetRequestKeys) {
        serverAPI = FcrBoardServerAPI(host: keys.host,
                                      appId: keys.agoraAppId,
                                      token: keys.token,
                                      roomId: info.roomInfo.roomUuid,
                                      userId: info.localUserInfo.userUuid,
                                      logTube: self.logger)
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
        guard let config = info.roomProperties?.toObj(FcrBooardConfigOfExtra.self),
              boardRoom == nil else {
                  return
              }
        
        // init
        let boardRegion = FcrBoardRegion(rawValue: config.boardRegion) ?? .cn
        let backgroundColor = UIConfig.netlessBoard.backgroundColor
        let room = FcrBoardRoom(appId: config.boardAppId,
                                 region: boardRegion,
                                 backgroundColor: backgroundColor)
        room.delegate = self
        
        room.logTube = self
        
        let ratio = view.ratio()
        
        let joinConfig = FcrBoardRoomJoinConfig(roomId: config.boardId,
                                                roomToken: config.boardToken,
                                                boardRatio: Float(ratio),
                                                hasOperationPrivilege: isTeacher,
                                                userId: info.localUserInfo.userUuid,
                                                userName: info.localUserInfo.userName)
        
        AgoraLoading.loading(in: view)
        
        joinBoardRoom(room,
                      config: joinConfig) { [weak self] mainWindow in
            guard let `self` = self else {
                return
            }
            
            AgoraLoading.hide()
            
            self.log(content: "join successfully",
                     extra: nil,
                     type: .info)
            
            self.mainWindow = mainWindow
            mainWindow.delegate = self
            mainWindow.logTube = self
            
            self.initCondition.needJoin = false
            
            self.setUpInitialState()
        }
        
        boardRoom = room
    }
    
    func joinBoardRoom(_ room: FcrBoardRoom,
                       config: FcrBoardRoomJoinConfig,
                       success: @escaping (FcrBoardMainWindow) -> Void) {
        room.join(config: config,
                  superView: view,
                  success: success) { [weak room] error in
            guard let `room` = room else {
                return
            }
            
            self.joinBoardRoom(room,
                               config: config,
                               success: success)
            
            self.log(content: "join unsuccessfully",
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
        
        AgoraLoading.hide()
        
        sendMessage(signal: .onBoardSaveResult(.savedToAlbum))
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
        if !initCondition.configComplete,
           let configExtra = info.roomProperties?.toObj(FcrBooardConfigOfExtra.self) {
            initCondition.configComplete = true
        }
    }
    
    private func analyzeGrantedUsersFromRoomProperties() {
        var grantedUsers = [String]()

        if let usageExtra = info.roomProperties?.toObj(FcrBooardUsageOfExtra.self) {
            grantedUsers = Array(usageExtra.grantedUsers.keys)
        }
        
        // 为保证逻辑，若本地为老师，将老师uuid加入grantedUsers中
        if isTeacher,
           !grantedUsers.contains(info.localUserInfo.userUuid) {
            grantedUsers.append(info.localUserInfo.userUuid)
        }
        
        var newLocalPrivilege = true
        if !isTeacher,
           !grantedUsers.contains(info.localUserInfo.userUuid) {
            newLocalPrivilege = false
        }
        
        var privilegeNeedChanged = (newLocalPrivilege != hasOperationPrivilege)
        
        guard privilegeNeedChanged else {
            sendMessage(signal: .getBoardGrantedUsers(grantedUsers))
            return
        }
        
        mainWindow?.updateOperationPrivilege(hasPrivilege: newLocalPrivilege,
                                             success: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.log(content: "updateOperationPrivilege",
                     extra: "\(newLocalPrivilege)",
                     type: .info)
            
            self.hasOperationPrivilege = newLocalPrivilege
            self.sendMessage(signal: .getBoardGrantedUsers(grantedUsers))
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
        if isTeacher {
            hasOperationPrivilege = true
        }
        
        initViews()
        ifNeedSetWindowAttributes()

        analyzeGrantedUsersFromRoomProperties()
    }
    
    func initViews() {
        guard info.localUserInfo.userRole != "observer" else {
            pageControl.agora_enable = false
            return
        }
        view.addSubview(pageControl)
        
        pageControl.addBtn.addTarget(self,
                                     action: #selector(onClickAddPage(_:)),
                                     for: .touchUpInside)
        pageControl.prevBtn.addTarget(self,
                                      action: #selector(onClickPrePage(_:)),
                                      for: .touchUpInside)
        pageControl.nextBtn.addTarget(self,
                                      action: #selector(onClickNextPage(_:)),
                                      for: .touchUpInside)
        
        view.addSubview(pageControl)
        
        pageControl.agora_enable = UIConfig.netlessBoard.pageControl.enable
        pageControl.agora_visible = hasOperationPrivilege
        
        pageControl.mas_makeConstraints { make in
            make?.left.equalTo()(view)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
            make?.bottom.equalTo()(view)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 34 : 32)
            make?.width.equalTo()(168)
        }
        
        guard let `mainWindow` = mainWindow else {
            return
        }
        
        let info = mainWindow.getPageInfo()
        
        pageControl.updatePage(index: Int(info.showIndex) + 1,
                               pages: Int(info.count))
    }
    
    func movePageControl(isRight: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            let move: CGFloat = UIDevice.current.agora_is_pad ? 49 : 44
            self.pageControl.transform = CGAffineTransform(translationX: isRight ? move : 0,
                                                           y: 0)
        }, completion: nil)
    }
    
    @objc func onClickAddPage(_ sender: UIButton) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        mainWindow.addPage()
    }
    
    @objc func onClickPrePage(_ sender: UIButton) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        let index = mainWindow.getPageInfo().showIndex - 1
        let finalIndex = (index < 0) ? 0 : index
        mainWindow.setPageIndex(index: finalIndex)
    }
    
    @objc func onClickNextPage(_ sender: UIButton) {
        guard let `mainWindow` = mainWindow else {
            return
        }
        let index = mainWindow.getPageInfo().showIndex + 1
        mainWindow.setPageIndex(index: index)
    }
}

// MARK: - FcrBoardRoomDelegate
extension FcrBoardWidget: FcrBoardRoomDelegate {
    func onConnectionStateUpdated(state: FcrBoardRoomConnectionState) {
        let extra = state.agDescription
        
        log(content: "onConnectionStateUpdated",
            extra: extra,
            type: .info)
        
        switch state {
        case .connected:
            AgoraLoading.hide()
        case .reconnecting:
            AgoraLoading.loading(in: view)
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
        pageControl.updatePage(index: Int(info.showIndex) + 1,
                               pages: Int(info.count))
    }
    
    func onUndoStateUpdated(enable: Bool) {
        sendMessage(signal: .boardStepChanged(.undoAble(enable)))
    }
    
    func onRedoStateUpdated(enable: Bool) {
        sendMessage(signal: .boardStepChanged(.redoAble(enable)))
    }
    
    func onWindowBoxStateChanged(state: FcrWindowBoxState) {
        sendMessage(signal: .windowStateChanged(state.toWidget))
        movePageControl(isRight: (state == .mini))
    }
    
    func onStartAudioMixing(filePath: String,
                            loopback: Bool,
                            replace: Bool,
                            cycle: Int) {
        let data = FcrBoardAudioMixingStartData(filePath: filePath,
                                                loopback: loopback,
                                                replace: replace,
                                                cycle: cycle)
        let type = FcrBoardAudioMixingRequestType.start(data)
        sendMessage(signal: .boardAudioMixingRequest(type))
    }
    
    func onPauseAudioMixing() {
        let type = FcrBoardAudioMixingRequestType.pause
        sendMessage(signal:.boardAudioMixingRequest(type))
    }
    
    func onResumeAudioMixing() {
        let type = FcrBoardAudioMixingRequestType.resume
        sendMessage(signal:.boardAudioMixingRequest(type))
    }
    
    func onStopAudioMixing() {
        let type = FcrBoardAudioMixingRequestType.stop
        sendMessage(signal: .boardAudioMixingRequest(type))
    }
    
    func onAudioMixingPositionUpdated(position: Int) {
        let type = FcrBoardAudioMixingRequestType.setPosition(position)
        sendMessage(signal: .boardAudioMixingRequest(type))
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
