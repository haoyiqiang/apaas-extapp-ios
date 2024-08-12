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
    weak var effectMixer: WhiteAudioEffectMixerBridge?
    weak var logTube: FcrBoardLogTube?
    
    override init() {
        super.init()
        let getRtc = Notification.Name(rawValue: "rtc.engine.object")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getRtcObject(_:)),
                                               name: getRtc,
                                               object: nil)
        
        let audioFileInfo = Notification.Name(rawValue: "rtc.engine.audio.file.info")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rtcAudioFileInfo(_:)),
                                               name: audioFileInfo,
                                               object: nil)

        let audioEffectState = Notification.Name(rawValue: "rtc.engine.audio.effect.state")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rtcAudioEffectStateChanged(_:)),
                                               name: audioEffectState,
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
    
    @objc func rtcAudioFileInfo(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let info = object["info"] as? AgoraRtcAudioFileInfo else {
            return
        }
        
        log(content: #function,
            extra: "filePath: \(info.filePath), durationMs: \(info.durationMs)",
            type: .info)
        
        effectMixer?.setEffectDurationUpdate(info.filePath,
                                             duration: Int(info.durationMs))
    }
    
    @objc func rtcAudioEffectStateChanged(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let soundId = object["soundId"] as? Int,
              let state = object["state"] as? Int else {
            return
        }
        
        log(content: #function,
            extra: "soundId: \(soundId), state: \(state)",
            type: .info)
        
        effectMixer?.setEffectSoundId(soundId,
                                      stateChanged: state)
    }
    
    func log(content: String,
             extra: String? = nil,
             type: FcrBoardLogType,
             fromClass: AnyClass? = nil,
             funcName: String = #function,
             line: Int = #line) {
        var classType: AnyClass
        
        if let `fromClass` = fromClass {
            classType = fromClass
        } else {
            classType = self.classForCoder
        }
        
        logTube?.onBoardLog(content: content,
                            extra: extra,
                            type: type,
                            fromClass: classType,
                            funcName: funcName,
                            line: line)
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
        log(content: #function,
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.getEffectsVolume();
    }
    
    func setEffectsVolume(_ volume: Double) -> Int32 {
        log(content: #function,
            extra: "volume: \(volume)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.setEffectsVolume(volume)
    }
   
    func setVolumeOfEffect(_ soundId: Int32,
                           withVolume volume: Double) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId), volume: \(volume)",
            type: .info,
            fromClass: WhiteSDK.self)
        
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
                    startPos: Int32,
                    identifier: String) -> Int32 {
        var extra = "soundId: \(soundId), filePath: \(filePath ?? "nil"), loopCount: \(loopCount), pitch: \(pitch), pan: \(pan), gain: \(gain) publish: \(publish), startPos: \(startPos), identifier: \(identifier)"
        
        if identifier == "mediaPlayer" {
            let tGain: Double = 300
            
            extra += ", mediaPlayer final gain: \(tGain)"
            
            log(content: #function,
                extra: extra,
                type: .info,
                fromClass: WhiteSDK.self)
            
            return rtc.playEffect(soundId,
                                  filePath: filePath,
                                  loopCount: loopCount,
                                  pitch: pitch,
                                  pan: pan,
                                  gain: tGain,
                                  publish: publish)
        } else {
            let tGain: Double = 300
            
            extra += ", ppt final gain: \(tGain)"
            
            log(content: #function,
                extra: extra,
                type: .info,
                fromClass: WhiteSDK.self)
            
            return rtc.playEffect(soundId,
                                  filePath: filePath,
                                  loopCount: loopCount,
                                  pitch: pitch,
                                  pan: pan,
                                  gain: tGain,
                                  publish: publish,
                                  startPos: startPos)
        }
    }

    func stopEffect(_ soundId: Int32) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.stopEffect(soundId);
    }
    
    func stopAllEffects() -> Int32 {
        log(content: #function,
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.stopAllEffects()
    }
    
    func preloadEffect(_ soundId: Int32,
                       filePath: String?) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId), filePath: \(filePath ?? "")",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.preloadEffect(soundId,
                                 filePath: filePath)
    }

    func unloadEffect(_ soundId: Int32) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.unloadEffect(soundId)
    }
    
    func pauseEffect(_ soundId: Int32) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.pauseEffect(soundId)
    }
        
    func pauseAllEffects() -> Int32 {
        log(content: #function,
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.pauseAllEffects()
    }

    func resumeEffect(_ soundId: Int32) -> Int32 {
        log(content: #function,
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.resumeEffect(soundId)
    }

    func resumeAllEffects() -> Int32 {
        log(content: #function,
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.resumeAllEffects()
    }
    
    func setEffectPosition(_ soundId: Int32,
                           pos: Int) -> Int32 {
        log(content: #function,
            extra: "soundId: \(soundId), pos: \(pos)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.setEffectPosition(soundId,
                                     pos: pos)
    }

    func getEffectCurrentPosition(_ soundId: Int32) -> Int32 {
//        log(content: #function,
//            extra: "soundId: \(soundId)",
//            type: .info,
//            fromClass: WhiteSDK.self)
        
        return rtc.getEffectCurrentPosition(soundId)
    }
    
    func getEffectDuration(_ filePath: String) -> Int32 {
        log(content: #function,
            extra: "filePath: \(filePath)",
            type: .info,
            fromClass: WhiteSDK.self)
        
        return rtc.getEffectDuration(filePath)
    }
}
