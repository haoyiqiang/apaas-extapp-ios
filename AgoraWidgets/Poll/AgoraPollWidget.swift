//
//  AgoraPollWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import AgoraWidget
import AgoraLog
import Masonry
import Armin

@objcMembers public class AgoraPollWidget: AgoraBaseWidget {
    private var logger: AgoraLogger
    private var serverApi: AgoraPollServerAPI?
    
    private lazy var studentView: AgoraPollStudentView = {
        return AgoraPollStudentView(delegate: self)
    }()
    
    private lazy var teacherView: AgoraPollTeacherView = {
        // TODO: teacher
        return AgoraPollTeacherView(delegate: self)
    }()
    
    private var curExtra: AgoraPollExtraModel? {
        didSet {
            handleProperties()
        }
    }
    
    private var curUserProps: AgoraPollUserPropModel? {
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
           let pollExtraModel = roomProps.toObj(AgoraPollExtraModel.self) {
            curExtra = pollExtraModel
        }
        
        if let userProps = info.localUserProperties,
           let pollUserModel = userProps.toObj(AgoraPollUserPropModel.self),
           let extra = curExtra,
           pollUserModel.pollId == extra.pollId {
            curUserProps = pollUserModel
        }
        
        if isTeacher {
            view.addSubview(teacherView)
            teacherView.mas_makeConstraints { make in
                make?.left.right()?.top()?.bottom().equalTo()(0)
            }
        } else {
            view.addSubview(studentView)
            studentView.mas_makeConstraints { make in
                make?.left.right()?.top()?.bottom().equalTo()(0)
            }
        }
        
        handleProperties()
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        if let pollExtraModel = properties.toObj(AgoraPollExtraModel.self) {
            curExtra = pollExtraModel
        }
    }
    
    public override func onWidgetUserPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        if let pollUserModel = properties.toObj(AgoraPollUserPropModel.self),
           let extra = curExtra,
           pollUserModel.pollId == extra.pollId {
            curUserProps = pollUserModel
        }
    }

    public override func onMessageReceived(_ message: String) {
        logInfo("onMessageReceived:\(message)")
        
        if let baseInfo = message.toAppBaseInfo() {
            serverApi = AgoraPollServerAPI(baseInfo: baseInfo,
                                             roomId: info.roomInfo.roomUuid,
                                             uid: info.localUserInfo.userUuid)
        }
        
        if let signal = message.vcMessageToSignal() {
            
        }
    }
}

// MARK: - AgoraPollTeacherViewDelegate
extension AgoraPollWidget: AgoraPollTeacherViewDelegate {
    func didStartpoll(isSingle: Bool,
                        pollingItems: [String]) {
        // TODO: 教师操作
    }
    
    func didStoppoll(pollId: String) {
        // TODO: 教师操作
    }
}

// MARK: - AgoraPollStudentViewDelegate
extension AgoraPollWidget: AgoraPollStudentViewDelegate {
    func didSubmitIndexs(_ indexs: [Int]) {
        guard let server = serverApi,
        let extra = curExtra else {
            return
        }
        server.submit(pollId: extra.pollId,
                      selectIndex: indexs) { [weak self] in
            self?.logInfo("submit success:\(indexs)")
        } fail: { [weak self] error in
            self?.logError(error.localizedDescription)
        }
    }
}

// MARK: - ArminDelegate
extension AgoraPollWidget: ArminDelegate {
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
extension AgoraPollWidget: ArLogTube {
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
private extension AgoraPollWidget {
    func handleProperties() {
        guard let extra = curExtra else {
            return
        }
        if isTeacher {
            
        } else {
            let isEnd = (extra.pollState == .end || curUserProps != nil)
            studentView.update(isSingle: extra.mode == .single,
                               isEnd: isEnd,
                               title: extra.pollTitle,
                               items: extra.pollItems,
                               pollDetails: extra.pollDetails)
        }
    }
    
    func sendMessage(_ signal: AgoraPollInteractionSignal) {
        guard let text = signal.toMessageString() else {
            logError("signal encode error!")
            return
        }
        sendMessage(text)
    }
    
    func logInfo(_ log: String) {
        logger.log("[Poll Widget \(info.widgetId)] \(log)",
                   type: .info)
    }
    
    func logError(_ log: String) {
        logger.log("[Poll Widget \(info.widgetId)] \(log)",
                   type: .error)
    }
}
