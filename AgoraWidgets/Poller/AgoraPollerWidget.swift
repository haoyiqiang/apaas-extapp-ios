//
//  AgoraPollerWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import Armin
import Masonry
import AgoraLog
import AgoraWidget

@objcMembers public class AgoraPollerWidget: AgoraBaseWidget {
    private var logger: AgoraLogger
    private var serverApi: AgoraPollerServerApi?
    
    private lazy var studentView: AgoraPollerStudentView = {
        return AgoraPollerStudentView(delegate: self)
    }()
    
    private lazy var teacherView: AgoraPollerTeacherView = {
        // TODO: teacher
        return AgoraPollerTeacherView(delegate: self)
    }()
    
    private var curExtra: AgoraPollerExtraModel? {
        didSet {
            handleProperties()
        }
    }
    
    private var curUserProps: AgoraPollerUserPropModel? {
        didSet {
            handleProperties()
        }
    }
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        let cachesFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                               .userDomainMask,
                                                               true)[0]
        let logFolder = cachesFolder.appending("/AgoraLog")
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: logFolder,
                               isDirectory: nil) {
            try? manager.createDirectory(atPath: logFolder,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        }
        self.logger = AgoraLogger(folderPath: logFolder,
                                  filePrefix: widgetInfo.widgetId,
                                  maximumNumberOfFiles: 5)
        
        super.init(widgetInfo: widgetInfo)
    }
    
    // MARK: widget callback
    public override func onWidgetDidLoad() {
        if let roomProps = info.roomProperties,
           let pollerExtraModel = roomProps.toObj(AgoraPollerExtraModel.self) {
            curExtra = pollerExtraModel
        }
        
        if let userProps = info.localUserProperties,
           let pollerUserModel = userProps.toObj(AgoraPollerUserPropModel.self),
           let extra = curExtra,
           pollerUserModel.pollingId == extra.pollingId {
            curUserProps = pollerUserModel
        }
        
        if isTeacher {
            view.addSubview(teacherView)
            teacherView.mas_makeConstraints { make in
                make?.left.equalTo()(0)
                make?.top.equalTo()(0)
                make?.width.equalTo()(0)
                make?.height.equalTo()(0)
            }
        } else {
            view.addSubview(studentView)
            studentView.mas_makeConstraints { make in
//                make?.left.equalTo()(0)
//                make?.top.equalTo()(0)
//                make?.width.equalTo()(0)
//                make?.height.equalTo()(0)
                make?.centerX.centerY().equalTo()(0)
                make?.width.equalTo()(348)
                make?.height.equalTo()(300)
            }
        }
        
        handleProperties()
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        if let pollerExtraModel = properties.toObj(AgoraPollerExtraModel.self) {
            curExtra = pollerExtraModel
        }
    }
    
    public override func onWidgetUserPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        if let pollerUserModel = properties.toObj(AgoraPollerUserPropModel.self),
           let extra = curExtra,
           pollerUserModel.pollingId == extra.pollingId {
            curUserProps = pollerUserModel
        }
    }

    public override func onMessageReceived(_ message: String) {
        logInfo("onMessageReceived:\(message)")
        
        if let baseInfo = message.toAppBaseInfo() {
            serverApi = AgoraPollerServerApi(baseInfo: baseInfo,
                                             roomId: info.roomInfo.roomUuid,
                                             uid: info.localUserInfo.userUuid)
        }
        
        if let signal = message.vcMessageToSignal() {
            
        }
    }
}

// MARK: - AgoraPollerTeacherViewDelegate
extension AgoraPollerWidget: AgoraPollerTeacherViewDelegate {
    func didStartPoller(isSingle: Bool,
                        pollingItems: [String]) {
        // TODO: 教师操作
    }
    
    func didStopPoller(pollerId: String) {
        // TODO: 教师操作
    }
}

// MARK: - AgoraPollerStudentViewDelegate
extension AgoraPollerWidget: AgoraPollerStudentViewDelegate {
    func didSubmitIndexs(_ indexs: [Int]) {
        guard let server = serverApi,
        let extra = curExtra else {
            return
        }
        server.submit(pollingId: extra.pollingId,
                      selectIndex: indexs) {[weak self] in
            self?.logInfo("submit success:\(indexs)")
        } fail: {[weak self] error in
            self?.logError(error.localizedDescription)
        }
    }
}

// MARK: - ArminDelegate
extension AgoraPollerWidget: ArminDelegate {
    public func armin(_ client: Armin,
               requestSuccess event: ArRequestEvent,
               startTime: TimeInterval,
               url: String) {
        
    }
    
    public func armin(_ client: Armin,
               requestFail error: ArError,
               event: ArRequestEvent,
               url: String) {
        
    }
}

// MARK: - ArLogTube
extension AgoraPollerWidget: ArLogTube {
    public func log(info: String,
             extra: String?) {
        logInfo("\(extra) - \(info)")
    }
    
    public func log(warning: String,
             extra: String?) {
        log(warning: warning,
            extra: extra)
    }
    
    public func log(error: ArError,
             extra: String?) {
        logError("\(extra) - \(error.localizedDescription)")
    }
}

// MARK: - private
private extension AgoraPollerWidget {
    func handleProperties() {
        guard let extra = curExtra else {
            return
        }
        if isTeacher {
            
        } else {
            let isEnd = (extra.pollingState == .end || curUserProps != nil)
            studentView.update(isSingle: extra.mode == .single,
                               isEnd: isEnd,
                               title: extra.pollingTitle,
                               items: extra.pollingItems,
                               pollingDetails: extra.pollingDetails)
        }
    }
    
    func sendMessage(_ signal: AgoraPollerInteractionSignal) {
        guard let text = signal.toMessageString() else {
            logError("signal encode error!")
            return
        }
        sendMessage(text)
    }
    
    func logInfo(_ log: String) {
        logger.log("[Poller Widget \(info.widgetId)] \(log)",
                   type: .info)
    }
    
    func logError(_ log: String) {
        logger.log("[Poller Widget \(info.widgetId)] \(log)",
                   type: .error)
    }
}
