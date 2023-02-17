//
//  AgoraRtmWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import AgoraUIBaseViews
import AgoraWidget
import Armin

@objcMembers public class AgoraChatRtmWidget: AgoraNativeWidget {
    
    private lazy var mainView = AgoraChatMainView()
        
    private var serverAPI: AgoraChatServerAPI?
        
    public override func onLoad() {
        super.onLoad()
        
        mainView.delegate = self
        view.addSubview(mainView)
                
        mainView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        let roomType = AgoraWidgetRoomType(rawValue: Int(info.roomInfo.roomType)) ?? .small
        let roleType = AgoraWidgetRoleType(rawValue: info.localUserInfo.userRole) ?? .student

        var items = AgoraChatMainViewItem.allCases
        items.removeAll([.emoji,.image])
        
        switch roomType {
        case .oneToOne:
            items.removeAll([.announcement, .muteAll])
        default:
            break
        }
        
        switch roleType {
        case .student:
            items.removeAll([.announcement, .muteAll])
        case .observer:
            items.removeAll([.input])
        default:
            break
        }
        let extra = ["viewItem": items.agDescription]
        log(content: "update view items",
            extra: extra.agDescription,
            type: .info )
        mainView.updateViewItems(items)
        
        fetchHistoryMessage()
    }
    
    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        let dict = message.toDictionary()
        
        if let keys = message.toRequestKeys() {
            serverAPI = AgoraChatServerAPI(host: keys.host,
                                           appId: keys.agoraAppId,
                                           token: keys.token,
                                           roomId: info.roomInfo.roomUuid,
                                           userId: info.localUserInfo.userUuid,
                                           logTube: logger)
            fetchHistoryMessage()
        }
        if let d = dict?["keys"] as? [String: Any] {

        } else if let d = dict?["message"] as? [String: Any] {
            self.updateMessageWithDict(d)
            sendSignal(.messageReceived)
        } else if let isMute = dict?["isMute"] as? Bool {
            // rtm只有全体禁言，没有单个禁言
            mainView.updateBottomBarMuteState(islocalMuted: false,
                                              isAllMuted: isMute,
                                              localMuteAuth: isTeacher)
        }
    }
    
    func fetchHistoryMessage() {
        log(content: "fetch history messages",
            extra: nil,
            type: .info )
        serverAPI?.fetchHistoryMessage(success: { [weak self] list in
            guard let `self` = self else {
                return
            }
            self.setupHistoryMessageWithList(list)
        }, failure: { [weak self] error in
            let extra = ["error": error.localizedDescription]
            self?.log(content: "fetch history messages",
                      extra: extra.agDescription,
                      type: .error )
        })
    }
}

// MARK: - AgoraChatMainViewDelegate
extension AgoraChatRtmWidget: AgoraChatMainViewDelegate {
    func onSendTextMessage(_ message: String) {
        let extra = ["message": message]
        log(content: "send text message",
            extra: extra.agDescription,
            type: .info)
        serverAPI?.sendMessage(message,
                               success: nil,
                               failure: nil)
    }
        
    func onShowErrorMessage(_ errorMessage: String) {
        let extra = ["errorMessage": errorMessage]
        log(content: "error message",
            extra: extra.agDescription,
            type: .error)
        sendSignal(.error(errorMessage))
    }
    
    func onSendImageData(_ data: Data) {
        
    }
    
    func onClickAllMuted(_ isAllMuted: Bool) {
        
    }
    
    func onSetAnnouncement(_ announcement: String?) {
        
    }
}

// MARK: - Private
private extension AgoraChatRtmWidget {
    func updateMessageWithDict(_ dict: [String: Any]) {
        let extra = ["messages": dict.description]
        log(content: "messages update",
            extra: extra.agDescription,
            type: .info)
        guard let model = dict.rtmMessageToMessageViewType(localUserId: info.localUserInfo.userUuid) else {
            return
        }
        mainView.appendMessages([model])
    }
    
    func sendSignal(_ signal: AgoraChatInteractionSignal) {
        guard let message = signal.toMessageString() else {
            return
        }
        sendMessage(message)
    }
    
    func setupHistoryMessageWithList(_ list: [Dictionary<String, Any>]) {
        var temp = [AgoraChatMessageViewType]()
        for dict in list {
            guard let model = dict.rtmHistoryMessageToMessageViewType(localUserId: info.localUserInfo.userUuid) else {
                continue
            }
            temp.append(model)
        }
        let extra = ["history": list.description]
        log(content: "set history messages",
            extra: extra.agDescription,
            type: .info)
        mainView.setupHistoryMessages(list: temp)
    }
}
