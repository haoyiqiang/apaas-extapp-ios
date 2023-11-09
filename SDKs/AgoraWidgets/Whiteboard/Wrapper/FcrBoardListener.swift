//
//  FcrBoardListener.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import AgoraRtcKit
import Foundation
import Whiteboard

class FcrBoardListener: NSObject {
    weak var roomNeedObserve: FcrBoardRoomNeedObserve?
    weak var mainWindowNeedObserve: FcrBoardMainWindowNeedObserve?
    weak var rtc: AgoraRtcEngineKit!
    
    override init() {
        super.init()
        let getRtc = Notification.Name(rawValue: "rtc.engine.object")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getRtcObject(_:)),
                                               name: getRtc,
                                               object: nil)
        
        let needRtc = Notification(name: Notification.Name(rawValue: "need.rtc.engine.object"))
        
        NotificationCenter.default.post(needRtc)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func getRtcObject(_ notification: Notification) {
        rtc = notification.object as? AgoraRtcEngineKit
    }
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
    
    func pauseAudioMixing() {
        mainWindowNeedObserve?.onPauseAudioMixing()
    }
    
    func resumeAudioMixing() {
        mainWindowNeedObserve?.onResumeAudioMixing()
    }
    
    func setAudioMixingPosition(_ position: Int) {
        mainWindowNeedObserve?.onAudioMixingPositionUpdated(position: position)
    }
}

extension FcrBoardListener: WhiteAudioEffectMixerBridgeDelegate {
    func getEffectsVolume() -> Double {
        return rtc.getEffectsVolume();
    }
    
    func setEffectsVolume(_ volume: Double) -> Int32 {
        return rtc.setEffectsVolume(volume)
    }
   
    func setVolumeOfEffect(_ soundId: Int32, withVolume volume: Double) -> Int32 {
        return rtc.setVolumeOfEffect(soundId,
                                     withVolume: volume)
    }

    func playEffect(_ soundId: Int32,
                    filePath: String?,
                    loopCount: Int32,
                    pitch: Double,
                    pan: Double,
                    gain: Double,
                    publish: Bool,
                    startPos: Int32) -> Int32 {
        return rtc.playEffect(soundId,
                              filePath: filePath,
                              loopCount: loopCount,
                              pitch: pitch,
                              pan: pan,
                              gain: gain,
                              publish: publish,
                              startPos: startPos)
    }

    func stopEffect(_ soundId: Int32) -> Int32 {
        return rtc.stopEffect(soundId);
    }
    
    func stopAllEffects() -> Int32 {
        return rtc.stopAllEffects()
    }
    
    func preloadEffect(_ soundId: Int32, filePath: String?) -> Int32 {
        return rtc.preloadEffect(soundId, filePath: filePath)
    }

    func unloadEffect(_ soundId: Int32) -> Int32 {
        return rtc.unloadEffect(soundId)
    }
    
    func pauseEffect(_ soundId: Int32) -> Int32 {
        return rtc.pauseEffect(soundId)
    }
        
    func pauseAllEffects() -> Int32 {
        return rtc.pauseAllEffects()
    }

    func resumeEffect(_ soundId: Int32) -> Int32 {
        return rtc.resumeEffect(soundId)
    }

    func resumeAllEffects() -> Int32 {
        return rtc.resumeAllEffects()
    }
    
    func setEffectPosition(_ soundId: Int32,
                           pos: Int) -> Int32 {
        return rtc.setEffectPosition(soundId,
                                     pos: pos)
    }

    func getEffectCurrentPosition(_ soundId: Int32) -> Int32 {
        return rtc.getEffectCurrentPosition(soundId)
    }
}
