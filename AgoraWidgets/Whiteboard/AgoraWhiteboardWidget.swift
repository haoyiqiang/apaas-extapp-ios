//
//  AgoraWhiteboardWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/2.
//

import AgoraWidget
import Whiteboard
import AgoraLog
import Masonry

struct InitCondition {
    var configComplete = false
    var needInit = false
    var needJoin = false
}

@objcMembers public class AgoraWhiteboardWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    
    private(set) var contentView: UIView!
    
    var whiteSDK: WhiteSDK?
    var room: WhiteRoom?
    
    var dt: AgoraWhiteboardWidgetDT
    
    var initMemberStateFlag: Bool = false
    
    var logger: AgoraWidgetLogger

    var initCondition = InitCondition() {
        didSet {
            if initCondition.configComplete,
               initCondition.needInit,
               initCondition.needJoin {
                initWhiteboard()
                joinWhiteboard()
            }
        }
    }
    
    // MARK: - AgoraBaseWidget
    public override init(widgetInfo: AgoraWidgetInfo) {
        self.dt = AgoraWhiteboardWidgetDT(extra: AgoraWhiteboardExtraInfo.fromExtraDic(widgetInfo.extraInfo),
                                          localUserInfo: widgetInfo.localUserInfo)
        
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
        self.dt.delegate = self
        
        initCondition.needInit = true
        
        if let wbProperties = widgetInfo.roomProperties?.toObj(AgoraWhiteboardPropExtra.self) {
            dt.propsExtra = wbProperties
        }
    }
    
    // MARK: widget callback
    public override func onLocalUserInfoUpdated(_ localUserInfo: AgoraWidgetUserInfo) {
        dt.localUserInfo = localUserInfo
    }
    
    public override func onMessageReceived(_ message: String) {
        log(.info,
            content: "onMessageReceived:\(message)")
        
        if let signal = message.toBoardSignal() {
            switch signal {
            case .JoinBoard:
                initCondition.needJoin = true
            case .MemberStateChanged(let agoraWhiteboardMemberState):
                handleMemberState(state: agoraWhiteboardMemberState)
            case .AudioMixingStateChanged(let agoraBoardAudioMixingData):
                handleAudioMixing(data: agoraBoardAudioMixingData)
            case .BoardGrantDataChanged(let list):
                handleBoardGrant(list:list)
            case .BoardPageChanged(let changeType):
                handlePageChange(changeType: changeType)
            case .BoardStepChanged(let changeType):
                handleStepChange(changeType: changeType)
            case .ClearBoard:
                // 清屏，保留ppt
                room?.cleanScene(false)
            case .OpenCourseware(let courseware):
                handleOpenCourseware(info: courseware)
            default:
                break
            }
        }
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        guard let wbProperties = properties.toObj(AgoraWhiteboardPropExtra.self) else {
            return
        }
        log(.info,
            content: "onWidgetRoomPropertiesUpdated:\(properties)")
        dt.propsExtra = wbProperties
    }
    
    public override func onWidgetRoomPropertiesDeleted(_ properties: [String : Any]?,
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        log(.info,
            content: "onWidgetRoomPropertiesUpdated:\(keyPaths)")
        guard let wbProperties = properties?.toObj(AgoraWhiteboardPropExtra.self) else {
            dt.propsExtra = nil
            return
        }
        dt.propsExtra = wbProperties
    }
    
    func log(_ type: AgoraWhiteboardLogType,
             content: String) {
        switch type {
        case .info:
            log(content: "[Whiteboard widget] \(content)",
                type: .info)
        case .warning:
            log(content: "[Whiteboard widget] \(content)",
                type: .warning)
        case .error:
            log(content: "[Whiteboard widget] \(content)",
                type: .error)
        default:
            log(content: "[Whiteboard widget] \(content)",
                type: .info)
        }
    }
    
    deinit {
        room?.disconnect(nil)
        room = nil
        whiteSDK = nil
    }
}

// MARK: - private
extension AgoraWhiteboardWidget {
    func sendMessage(signal: AgoraBoardInteractionSignal) {
        guard let text = signal.toMessageString() else {
            log(.error,
                content: "signal encode error!")
            return
        }
        sendMessage(text)
    }
    
    func initWhiteboard() {
        guard let whiteSDKConfig = dt.getWhiteSDKConfigToInit(),
              whiteSDK == nil else {
            return
        }
        
        let wkConfig = dt.getWKConfig()
        contentView = WhiteBoardView(frame: .zero,
                                     configuration: wkConfig)
        
        contentView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        whiteSDK = WhiteSDK(whiteBoardView: contentView as! WhiteBoardView,
                            config: whiteSDKConfig,
                            commonCallbackDelegate: self,
                            audioMixerBridgeDelegate: self)
        
        // 需要先将白板视图添加到视图栈中再加入白板
        view.addSubview(contentView)
        
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(view)
        }
        WhiteDisplayerState.setCustomGlobalStateClass(AgoraWhiteboardGlobalState.self)
        
        initCondition.needInit = false
    }
    
    func joinWhiteboard() {
        let ratio = view.bounds.height / view.bounds.width
        guard let sdk = whiteSDK,
              let roomConfig = dt.getWhiteRoomConfigToJoin(ratio: ratio) else {
            return
        }
        
        DispatchQueue.main.async {
            AgoraWidgetLoading.addLoading(in: self.view)
        }
        log(.info,
            content: "start join")
        sdk.joinRoom(with: roomConfig,
                     callbacks: self) { [weak self] (success, room, error) in
            DispatchQueue.main.async {
                AgoraWidgetLoading.removeLoading(in: self?.view)
            }
            guard let `self` = self else {
                return
            }
            guard success, error == nil ,
                  let whiteRoom = room else {
                self.log(.error,
                         content: "join room error :\(error?.localizedDescription)")
                self.dt.reconnectTime += 2
                self.sendMessage(signal: .BoardPhaseChanged(.Disconnected))
                return
            }
            self.log(.info,
                     content: "join room success")
            
            self.room = whiteRoom
            self.initRoomState(state: whiteRoom.state)
            
            self.dt.reconnectTime = 0
            self.initCondition.needJoin = false
        }
    }
    
    func ifUseLocalCameraConfig() -> Bool {
        guard dt.configExtra.autoFit,
              dt.localGranted,
              let cameraConfig = getLocalCameraConfig(),
              let `room` = room else {
            return false
        }
        room.moveCamera(cameraConfig.toNetless())
        return true
    }
    
    func getLocalCameraConfig() -> AgoraWhiteBoardCameraConfig? {
        let path = dt.scenePath.translatePath()
        return dt.localCameraConfigs[path]
    }
    
    // MARK: - message handle
    func handleOpenCourseware(info: AgoraBoardCoursewareInfo) {
        var appParam: WhiteAppParam?
        if let convert = info.convert,
           convert,
           let scenes = info.scenes {
            // 动态ppt翻页
            appParam = WhiteAppParam.createSlideApp("/\(info.resourceUuid)",
                                                    scenes: scenes.toNetless(),
                                                    title: info.resourceName)
        } else if let scenes = info.scenes {
            // pptx、pdf
            appParam = WhiteAppParam.createDocsViewerApp("/\(info.resourceUuid)",
                                                         scenes: scenes.toNetless(),
                                                         title: info.resourceName)
        } else {
            appParam = WhiteAppParam.createMediaPlayerApp(info.resourceUrl,
                                                          title: info.resourceName)
        }
        
        guard let param = appParam else {
            return
        }
        
        room?.addApp(param,
                     completionHandler: { appId in
                        print("\(appId)")
                     })
    }
    
    func handleMemberState(state: AgoraBoardMemberState) {
        dt.updateMemberState(state: state)
        if let curState = dt.currentMemberState {
            room?.setMemberState(curState)
        }
    }
    
    func handleAudioMixing(data: AgoraBoardAudioMixingData) {
        whiteSDK?.audioMixer?.setMediaState(data.stateCode,
                                            errorCode: data.errorCode)
    }
    
    func handleBoardGrant(list: Array<String>?) {
        guard let `room` = room else {
            return
        }
        let newState = dt.makeGlobalState(grantUsers: list)
        room.setGlobalState(newState)
    }
    
    func handlePageChange(changeType: AgoraBoardPageChangeType) {
        guard let `room` = room else {
            return
        }
        switch changeType {
        case .index(let index):
            room.setSceneIndex(UInt(index < 0 ? 0 : index)) {[weak self] success, error in
                if !success {
                    self?.log(.error,
                              content: error.debugDescription)
                }
            }
        case .count(let count):
            if count > dt.page.count {
                room.addPage()
                room.nextPage { [weak self] success in
                    if success {
                        self?.log(.info,
                                  content: "add page successfully")
                    }
                }
            } else {
                // 减少
                for i in dt.page.count ..< count {
                    room.removeScenes(dt.scenePath)
                }
            }
        }
    }
    
    func handleStepChange(changeType: AgoraBoardStepChangeType) {
        guard let `room` = room else {
            return
        }
        switch changeType {
        case .pre(let count):
            for _ in 0 ..< count {
                room.undo()
            }
        case .next(let count):
            for _ in 0 ..< count {
                room.redo()
            }
        default:
            break
        }
    }

    func initRoomState(state: WhiteRoomState) {
        guard let `room` = room else {
            return
        }
        
        // undo和redo只有在disableSerialization为false时生效
        room.disableSerialization(false)

        self.onIfTeacherFirstLogin(state: state.globalState as? AgoraWhiteboardGlobalState)
        
        if let boxState = room.state.windowBoxState,
           let widgetState = boxState.toWidget(){
            sendMessage(signal: .WindowStateChanged(widgetState))
        }
        
        dt.currentMemberState = dt.baseMemberState
        // 发送初始画笔状态的消息
        var colorArr = Array<Int>()
        dt.baseMemberState.strokeColor?.forEach { number in
            colorArr.append(number.intValue)
        }
        let widgetMember = AgoraBoardMemberState(dt.baseMemberState)
        self.sendMessage(signal: .MemberStateChanged(widgetMember))
        
        // 老师离开
        if let broadcastState = state.broadcastState {
            if broadcastState.broadcasterId == nil {
                room.scalePpt(toFit: .continuous)
                room.scaleIframeToFit()
            }
        }
        
        if let sceneState = state.sceneState {
            // 1. 取真实regionDomain
            if sceneState.scenes.count > 0,
               let ppt = sceneState.scenes[0].ppt,
               ppt.src.hasPrefix("pptx://") {
                let src = ppt.src
                let index = src.index(src.startIndex, offsetBy:7)
                let arr = String(src[index...]).split(separator: ".")
                dt.regionDomain = (dt.regionDomain == String(arr[0])) ? dt.regionDomain : String(arr[0])
            }
            
            // 2. scenePath 判断
            let paths = sceneState.scenePath.split(separator: "/")
            if  paths.count > 0 {
                let newScenePath = String(sceneState.scenePath.split(separator: "/")[0])
                dt.scenePath = "\(newScenePath)"
            }
            
            // 3. ppt 获取总页数，当前第几页
            room.scaleIframeToFit()
            if sceneState.scenes[sceneState.index] != nil {
                room.scalePpt(toFit: .continuous)
            }
            // page改变
            dt.page = AgoraBoardPageInfo(index: sceneState.index,
                                         count: sceneState.scenes.count)
            ifUseLocalCameraConfig()
            
        }
        
        if let cameraState = state.cameraState,
           dt.localGranted {
            // 如果本地被授权，则是本地自己设置的摄像机视角
            dt.localCameraConfigs[room.sceneState.scenePath] = cameraState.toWidget()
        }
    }
    
    func onIfTeacherFirstLogin(state: AgoraWhiteboardGlobalState?) {
        guard let `room` = room else {
            return
        }
        
        let teacherCompletion: (() -> Void) = { [weak self] in
            guard let `self` = self else {
                return
            }
            let newState = AgoraWhiteboardGlobalState()
            newState.materialList = self.dt.globalState.materialList
            newState.currentSceneIndex = self.dt.globalState.currentSceneIndex
            // 收回权限
            newState.grantUsers = Array<String>()
            // 设置globalState
            newState.teacherFirstLogin = true
            
            room.setGlobalState(newState)
            
            // 关闭当前所有课件
            room.removeScenes("/")
            // 打开课件
            if let list = self.dt.coursewareList {
                for item in list {
                    self.handleOpenCourseware(info: item)
                }
            }
        }
        
        let studentCompletion: (() -> Void) = { [weak self] in
            guard let `self` = self,
            let `room` = self.room else {
                return
            }
            var state = self.room?.globalState as? AgoraWhiteboardGlobalState
            if state == nil {
                state = AgoraWhiteboardGlobalState()
            }
            // 收回权限
            state!.grantUsers.append(self.info.localUserInfo.userUuid)

            room.setGlobalState(state!)
            
            // 打开新课件
            if let list = self.dt.coursewareList {
                for item in list {
                    self.handleOpenCourseware(info: item)
                }
            }
            
            self.sendMessage(signal: .BoardGrantDataChanged([self.info.localUserInfo.userUuid]))
        }
        
        if !dt.globalState.teacherFirstLogin {
            dt.localGranted = true
            onLocalGrantedChangedForBoardHandle(localGranted: true,
                                                completion: { [weak self] success in
                                                    guard let `self` = self,
                                                          success else {
                                                        return
                                                    }
                                                    self.isTeacher ? teacherCompletion() : studentCompletion()
                                                })
        } else {
            if let globalState = state {
                dt.globalState = globalState
            }
            if isTeacher {
               dt.localGranted = true
               onLocalGrantedChangedForBoardHandle(localGranted: true,
                                                   completion: nil)
           }
        }
    }
}
