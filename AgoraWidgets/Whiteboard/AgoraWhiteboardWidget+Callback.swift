//
//  AgoraWhiteboardWidget+Callback.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/7.
//

import Whiteboard

extension AgoraWhiteboardWidget: WhiteRoomCallbackDelegate {
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        log(.info,
            content: modifyState.description)
        guard let `room` = room else {
            return
        }
        
        if let memberState = modifyState.memberState {
            return
        }
        
        if let boxState = modifyState.windowBoxState,
           let widgetState = boxState.toWidget(){
            sendMessage(signal: .WindowStateChanged(widgetState))
        }
        
        // 老师离开
        if let broadcastState = modifyState.broadcastState {
            if broadcastState.broadcasterId == nil {
                room.scalePpt(toFit: .continuous)
                room.scaleIframeToFit()
            }
            return
        }
        
        if let state = modifyState.globalState as? AgoraWhiteboardGlobalState {
            dt.globalState = state
            return
        }
        
        if let sceneState = modifyState.sceneState {
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
            let newScenePath = sceneState.scenePath.split(separator: "/")[0]
            if "/\(newScenePath)" != dt.scenePath {
                dt.scenePath = "/\(newScenePath)"
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
            return
        }
        
        if let cameraState = modifyState.cameraState,
           dt.localGranted {
            // 如果本地被授权，则是本地自己设置的摄像机视角
            dt.localCameraConfigs[room.sceneState.scenePath] = cameraState.toWidget()
            return
        }
    }
    
    public func firePhaseChanged(_ phase: WhiteRoomPhase) {
        sendMessage(signal: .BoardPhaseChanged(phase.toWidget()))
        
        log(.info,
            content: "phase: \(phase.strValue)")
        if phase == .connected {
            AgoraWidgetLoading.removeLoading(in: self.view)
        }
        if phase == .disconnected {
            self.joinWhiteboard()
        }
    }
    
    public func fireCanRedoStepsUpdate(_ canRedoSteps: Int) {
        log(.info,
            content: "canRedoSteps:\(canRedoSteps)")
        sendMessage(signal: .BoardStepChanged(.redoCount(canRedoSteps)))
    }
    
    public func fireCanUndoStepsUpdate(_ canUndoSteps: Int) {
        log(.info,
            content: "canUndoSteps:\(canUndoSteps)")
        sendMessage(signal: .BoardStepChanged(.undoCount(canUndoSteps)))
    }
}

extension AgoraWhiteboardWidget: WhiteCommonCallbackDelegate {
    public func throwError(_ error: Error) {
        log(.error,
            content: "\(error.localizedDescription)")
    }
    
    public func logger(_ dict: [AnyHashable : Any]) {
        // {funName: string, message: id} funName 为对应 API 的名称
        log(.info,
            content: "\(dict.description)")
    }
}

extension AgoraWhiteboardWidget: WhiteAudioMixerBridgeDelegate {
    public func startAudioMixing(_ filePath: String,
                                 loopback: Bool,
                                 replace: Bool,
                                 cycle: Int) {
        let path = filePath.replacingOccurrences(of: "agoranetless",
                                                 with: "http")
        
        let p = path.replacingOccurrences(of: "mp4",
                                          with: "mp3")
        
        let request = AgoraBoardAudioMixingRequestData(requestType: .start,
                                                       filePath: p,
                                                       loopback: loopback,
                                                       replace: replace,
                                                       cycle: cycle)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    public func stopAudioMixing() {
        let request = AgoraBoardAudioMixingRequestData(requestType: .stop)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    public func setAudioMixingPosition(_ position: Int) {
        let request = AgoraBoardAudioMixingRequestData(requestType: .setPosition,
                                                       position: position)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
}

extension AgoraWhiteboardWidget: AGBoardWidgetDTDelegate {
    func onConfigComplete() {
        initCondition.configComplete = true
    }
    
    func onGrantUsersChanged(grantUsers: [String]) {
        log(.info,
            content: "grant users changed: \(grantUsers)")
        sendMessage(signal: .BoardGrantDataChanged(grantUsers))
    }
    
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool,
                                             completion: ((Bool) -> Void)?) {
        log(.info,
            content: "local granted: \(localGranted)")
        
        self.room?.setViewMode(localGranted ? .freedom : .broadcaster)
        
        room?.setWritable(localGranted,
                          completionHandler: {[weak self] isWritable, error in
                            guard let `self` = self else {
                                return
                            }
                            if let error = error {
                                self.log(.error,
                                         content: "setWritable error: \(error.localizedDescription)")
                                completion?(false)
                            } else {
                                self.room?.disableCameraTransform(!isWritable)
                                self.ifUseLocalCameraConfig()
                                self.room?.disableDeviceInputs(!localGranted)
                                if !self.initMemberStateFlag,
                                   isWritable {
                                    self.room?.setMemberState(self.dt.baseMemberState)
                                    self.initMemberStateFlag = true
                                }
                                completion?(isWritable)
                            }
                          })
    }
    
    func onOpenPublicCoursewares(list: Array<AgoraBoardCoursewareInfo>) {
        for item in list {
            self.handleOpenCourseware(info: item)
        }
    }

    func onPageIndexChanged(index: Int) {
        log(.info,
            content: "page index changed: \(index)")
        let changeType = AgoraBoardPageChangeType.index(index)
        sendMessage(signal: .BoardPageChanged(changeType))
    }
    
    func onPageCountChanged(count: Int) {
        log(.info,
            content: "page count changed: \(count)")
        let changeType = AgoraBoardPageChangeType.count(count)
        sendMessage(signal: .BoardPageChanged(changeType))
    }
    
    func onScenePathChanged(path: String) {
        ifUseLocalCameraConfig()
    }
}
