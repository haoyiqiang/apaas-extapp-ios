//
//  AgoraCountdownWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/5.
//

import AgoraWidget
import AgoraLog
import Masonry

@objcMembers public class AgoraCountdownTimerWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    private var timer: Timer?
    var logger: AgoraWidgetLogger
    
    // View
    private var countdownView = AgoraCountdownView(frame: .zero)

    // Original Data
    private var roomData: AgoraCountdownRoomData?
    private var objectCreateTimestamp: Int64?  // millisecond
    
    // View Data
    private var countdownState: AgoraCountdownState = .end {
        didSet {
            switch countdownState {
            case .duration:
                countdownView.timePageColor = .normal
            case .end:
                countdownView.timePageColor = .warning
            }
        }
    }
    
    private var countdownTimestamp: Int64 = 0 { // second
        didSet {
            if countdownTimestamp > 3 {
                countdownView.timePageColor = .normal
            } else {
                countdownView.timePageColor = .warning
            }
            
            let timeString = countdownTimestamp.formatStringMS.replacingOccurrences(of: ":",
                                                                                    with: "")
            let array = timeString.map({String($0)})
            
            countdownView.updateTimePages(timeList: array)
        }
    }
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
    }
    
    public override func onWidgetDidLoad() {
        super.onWidgetDidLoad()
        initViews()
        initConstraints()
        updateRoomData()
        updateViewData()
        updateViewFrame()
        
        log(content: info.roomProperties?.jsonString() ?? "nil",
            extra: nil,
            type: .info)
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths)
        updateRoomData()
        updateViewData()
        shouldStartTime()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }
    
    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        if let timestamp = message.toSyncTimestamp() {
            objectCreateTimestamp = timestamp
            initCurrentTimestamp()
            shouldStartTime()
        }
        
        log(content: message,
            type: .info)
    }
    
    deinit {
        stopTimer()
    }
}

// MARK: - View
private extension AgoraCountdownTimerWidget {
    func initViews() {
        view.addSubview(countdownView)
        
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor(hexString: "#2F4192")?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 6
    }
    
    func initConstraints() {
        countdownView.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.top()?.equalTo()(0)
        }
    }
    
    func updateViewFrame() {
        let size = ["width": countdownView.neededSize.width,
                    "height": countdownView.neededSize.height]
        
        guard let message = ["size": size].jsonString() else {
            return
        }
        
        sendMessage(message)
    }
}

// MARK: - Data
private extension AgoraCountdownTimerWidget {
    func updateRoomData() {
        guard let roomProperties = info.roomProperties,
              let data = roomProperties.toObj(AgoraCountdownRoomData.self) else {
            return
        }
        
        roomData = data
    }
    
    func updateViewData() {
        guard let data = roomData else {
            return
        }
        
        countdownState = data.state
    }
    
    func initCurrentTimestamp() {
        guard let data = roomData,
              let objectCreate = objectCreateTimestamp else {
            return
        }
        
        let end = data.startTime + (data.duration * 1000)                      // millisecond
        let countdownMillisecond = end - objectCreate                          // millisecond
        let countdown = (countdownMillisecond < 0) ? 0 : countdownMillisecond  // millisecond
        countdownTimestamp = Int64(ceil(TimeInterval(countdown) / 1000))       // second
    }
}

private extension AgoraCountdownTimerWidget {
    func shouldStartTime() {
        switch countdownState {
        case .duration:
            startTimer()
        case .end:
            stopTimer()
        }
    }
    
    func startTimer() {
        guard self.timer == nil else {
            return
        }
        
        func fireTimer() {
            let timer = Timer.scheduledTimer(withTimeInterval: 1,
                                             repeats: true,
                                             block: { [weak self] _ in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                
                                                if strongSelf.countdownTimestamp <= 0 {
                                                    strongSelf.stopTimer()
                                                    strongSelf.objectCreateTimestamp = nil
                                                } else {
                                                    strongSelf.countdownTimestamp -= 1
                                                }

            })
            
            RunLoop.main.add(timer,
                             forMode: .common)
            timer.fire()
            self.timer = timer
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fireTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
