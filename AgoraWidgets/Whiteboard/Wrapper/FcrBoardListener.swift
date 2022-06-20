//
//  FcrBoardListener.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import Foundation
import Whiteboard

class FcrBoardListener: NSObject {
    weak var roomNeedObserve: FcrBoardRoomNeedObserve?
    weak var mainWindowNeedObserve: FcrBoardMainWindowNeedObserve?
}

extension FcrBoardListener: WhiteCommonCallbackDelegate {
    func throwError(_ error: Error) {
        roomNeedObserve?.onThrowError(error)
    }
    
    func logger(_ dict: [AnyHashable : Any]) {
        roomNeedObserve?.onLogger(dict)
    }
}

extension FcrBoardListener: WhiteRoomCallbackDelegate {
    func firePhaseChanged(_ phase: WhiteRoomPhase) {
        roomNeedObserve?.onPhaseChanged(phase)
    }
    
    func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        guard let state = modifyState else {
            return
        }
        
        mainWindowNeedObserve?.onRoomStateChanged(state)
    }
    
    func fireCanUndoStepsUpdate(_ canUndoSteps: Int) {
        mainWindowNeedObserve?.onCanUndoStepsUpdate(canUndoSteps)
    }
    
    func fireCanRedoStepsUpdate(_ canRedoSteps: Int) {
        mainWindowNeedObserve?.onCanRedoStepsUpdate(canRedoSteps)
    }
}

extension FcrBoardListener: WhiteAudioMixerBridgeDelegate {
    func startAudioMixing(_ filePath: String,
                          loopback: Bool,
                          replace: Bool,
                          cycle: Int) {
        mainWindowNeedObserve?.onStartAudioMixing(filePath: filePath,
                                                  loopback: loopback,
                                                  replace: replace,
                                                  cycle: cycle)
    }
    
    func stopAudioMixing() {
        mainWindowNeedObserve?.onStopAudioMixing()
    }
    
    func setAudioMixingPosition(_ position: Int) {
        mainWindowNeedObserve?.onAudioMixingPositionUpdated(position: position)
    }
}
