//
//  AgoraRtmIMWidget.swift
//  AgoraWidgets
//
//  Created by Jonathan on 2021/12/16.
//

import AgoraUIBaseViews
import AgoraWidget
import Armin

fileprivate class AgoraRtmDataModel: NSObject {
    var host: String?
    var token: String?
    var agoraAppId: String?
}

@objcMembers public class AgoraRtmIMWidget: AgoraBaseWidget {
    
    private var contentView: UIView!
    
    private var topBar: AgoraRtmIMTopBar!
    
    private var messageList: AgoraRtmIMMessageListView!
    
    private var sendBar: AgoraRtmIMSendBar!
    
    private let dataModel = AgoraRtmDataModel()
    
    private let armin = Armin()
    
    private var fetchedHistory = false
        
    public override init(widgetInfo: AgoraWidgetInfo) {
        super.init(widgetInfo: widgetInfo)
        
        createViews()
        createConstraint()
        
        fetchHistoryMessage()
    }
    
    public override func onMessageReceived(_ message: String) {
        let dict = message.toDic()
        if let d = dict?["keys"] as? [String: Any] {
            self.updateDataModelWithDict(d)
        } else if let d = dict?["message"] as? [String: Any] {
            self.updateMessageWithDict(d)
            self.sendMessage("chatWidgetDidReceiveMessage")
        } else if let d = dict?["view"] as? [String: Any] {
            self.updateViewWithDict(d)
        } else if let isMute = dict?["isMute"] as? Bool {
            self.sendBar.isMute(isMute)
        }
    }
    
    func fetchHistoryMessage() {
        guard let host = dataModel.host,
              let appId = dataModel.agoraAppId else {
            return
        }
        let url = "\(host)/edu/apps/\(appId)/v2/rooms/\(info.roomInfo.roomUuid)/chat/messages"
        let params: [String : Any] = [
            "sort": 1,
        ]
        let requestTask = ArRequestTask(
            event: ArRequestEvent(name: "rtm-history-message"),
            type: ArRequestType.http(.get, url: url),
            timeout: .medium,
            header: self.headers(),
            parameters: params
        )
        let response: ArResponse = ArResponse.json { [weak self] (json) in
            if let data = json["data"] as? [String: Any],
               let list = data["list"] as? [Dictionary<String, Any>] {
                self?.setupHistoryMessageWithList(list)
            }
        }
        armin.request(task: requestTask,
                      responseOnMainQueue: true,
                      success: response) { error in
            return .resign
        }
    }
}
// MARK: - Private
private extension AgoraRtmIMWidget {
    func headers(token: String? = nil,
                 uid: String? = nil) -> [String: String] {
        let dic = ["Content-Type": "application/json",
                   "x-agora-token": dataModel.token ?? "",
                   "x-agora-uid": info.localUserInfo.userUuid]
        return dic
    }
    
    func roleName(role: String) -> String? {
        if role == "teacher" {
            return "fcr_rtm_im_teacher".agora_localized("AgoraWidgets")
        } else if role == "student" {
            return "fcr_rtm_im_student".agora_localized("AgoraWidgets")
        } else if role == "1" {
            return "fcr_rtm_im_teacher".agora_localized("AgoraWidgets")
        } else if role == "2" {
            return "fcr_rtm_im_student".agora_localized("AgoraWidgets")
        } else {
            return nil
        }
    }
    
    func updateDataModelWithDict(_ dict: [String: Any]) {
        guard let host = dict["host"] as? String,
            let token = dict["token"] as? String,
            let agoraAppId = dict["agoraAppId"] as? String else {
            return
        }
        dataModel.host = host
        dataModel.token = token
        dataModel.agoraAppId = agoraAppId
        if fetchedHistory == false {
            fetchedHistory = true
            fetchHistoryMessage()
        }
    }
    
    func updateMessageWithDict(_ dict: [String: Any]) {
        guard let timestamp = dict["timestamp"] as? Int,
              let content = dict["content"] as? String,
              let userDict = dict["user"] as? [String: Any],
              let name = userDict["userName"] as? String,
              let role = userDict["userRole"] as? String,
              let uuid = userDict["userUuid"] as? String else {
            return
        }
        let model = AgoraRtmMessageModel()
        model.timestamp = timestamp
        model.text = content
        model.name = name
        model.isMine = (uuid == self.info.localUserInfo.userUuid)
        model.roleName = self.roleName(role: role)
        messageList.appendMessage(message: model)
    }
    
    func setupHistoryMessageWithList(_ list: [Dictionary<String, Any>]) {
        var temp = [AgoraRtmMessageModel]()
        for dict in list {
            guard let timestamp = dict["sendTime"] as? Int,
                  let content = dict["message"] as? String,
                  let userDict = dict["fromUser"] as? [String: Any],
                  let name = userDict["userName"] as? String,
                  let role = userDict["role"] as? String,
                  let uuid = userDict["userUuid"] as? String else {
                continue
            }
            let model = AgoraRtmMessageModel()
            model.timestamp = timestamp
            model.text = content
            model.name = name
            model.isMine = (uuid == self.info.localUserInfo.userUuid)
            model.roleName = self.roleName(role: role)
            temp.append(model)
        }
        messageList.setupHistoryMessages(list: temp)
    }
    
    func updateViewWithDict(_ dict: [String: Any]) {
        if let topBarHidden = dict["hideTopBar"] as? Bool,
           topBarHidden == true {
            topBar.isHidden = true
            topBar.mas_remakeConstraints { make in
                make?.left.top().right().equalTo()(0)
                make?.height.equalTo()(0)
            }
        }
        
        if let inputHidden = dict["hideInput"] as? Bool,
           inputHidden == true {
            sendBar.isHidden = true
        }
    }
}
// MARK: - AgoraRtmIMInputViewDelegate
extension AgoraRtmIMWidget: AgoraRtmIMInputViewDelegate {
    func sendChatText(message: String) {
        guard let host = dataModel.host,
              let appId = dataModel.agoraAppId else {
            return
        }
        let url = "\(host)/edu/apps/\(appId)/v2/rooms/\(info.roomInfo.roomUuid)/from/\(info.localUserInfo.userUuid)/chat"
        let params: [String : Any] = [
            "message": message,
            "type": 1
        ]
        let requestTask = ArRequestTask(
            event: ArRequestEvent(name: "rtm-send-message"),
            type: ArRequestType.http(.post, url: url),
            timeout: .medium,
            header: self.headers(),
            parameters: params
        )
        let response: ArResponse = ArResponse.json { [weak self] (json) in
            if let data = json["data"] as? [String: Any],
               let message = data["message"] as? String,
               let timestamp = data["sendTime"] as? Int {
                // send message did success
            }
        }
        armin.request(task: requestTask,
                      responseOnMainQueue: true,
                      success: response) { error in
            return .resign
        }        
    }
}

// MARK: - AgoraRtmIMSendBarDelegate
extension AgoraRtmIMWidget: AgoraRtmIMSendBarDelegate {
    func onClickInputMessage() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        let inputView = AgoraRtmIMInputView()
        inputView.delegate = self
        window.addSubview(inputView)
        inputView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        window.layoutIfNeeded()
        inputView.startInput()
    }

    func onClickInputEmoji() {
        
    }
}
// MARK: - Creations
private extension AgoraRtmIMWidget {
    func createViews() {        
        contentView = UIView()
        contentView.backgroundColor = .white
        self.view.addSubview(contentView)
        
        topBar = AgoraRtmIMTopBar(frame: .zero)
        contentView.addSubview(topBar)
        
        messageList = AgoraRtmIMMessageListView(frame: .zero)
        contentView.addSubview(messageList)
        
        sendBar = AgoraRtmIMSendBar(frame: .zero)
        sendBar.delegate = self
        contentView.addSubview(sendBar)
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        topBar.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
            make?.height.equalTo()(34)
        }
        sendBar.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(34)
        }
        messageList.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(topBar.mas_bottom)?.offset()(0)
            make?.bottom.equalTo()(sendBar.mas_top)?.offset()(0)
        }
    }
}
