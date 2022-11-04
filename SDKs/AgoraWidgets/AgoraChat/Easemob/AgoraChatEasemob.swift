//
//  AgoraChatEasemob.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2022/7/20.
//

import Foundation
import AgoraChat

typealias EasemobSuccessCompletion = () -> ()
typealias EasemobStringCompletion = (String?) -> ()
typealias EasemobMuteStateCompletion = (_ muted: Bool) -> ()
typealias EasemobMessageListCompletion = ([AgoraChatMessage]?) -> ()
typealias EasemobFailureCompletion = (AgoraChatErrorType) -> ()

protocol AgoraChatEasemobDelegate: NSObjectProtocol {
    func didReceiveMessages(list: [AgoraChatMessage])
    func didSendMessages(list: [AgoraChatMessage])
    func didLocalMuteStateChanged(_ muted: Bool)
    func didAllMuteStateChanged(_ muted: Bool)
    func didReceiveAnnouncement(_ announcement: String?)
    func didConnectionStateChaned(_ state: AgoraChatConnectionState)
    func onEasemobLog(content: String,
                      extra: String?,
                      type: FcrEasemobLogType)
    func didOccurError(type: AgoraChatErrorType)
}

class AgoraChatEasemob: NSObject {
    private weak var delegate: AgoraChatEasemobDelegate?
    private(set) var userConfig: AgoraChatEasemobUserConfig
    private var chatRoomId: String
    
    // set after joining successfully
    private var chatRoom: AgoraChatroom?
    
    private var latestMessageId = ""
    
    private var retryCount = 0
    private let maxRetryCount = 10
    private let muteMemberKey = "muteMember"
    
    init(appKey: String,
         chatRoomId: String,
         userConfig: AgoraChatEasemobUserConfig,
         enableConsoleLog: Bool,
         delegate: AgoraChatEasemobDelegate?) {
        self.chatRoomId = chatRoomId
        self.userConfig = userConfig
        self.delegate = delegate
        super.init()
        
        let option = AgoraChatOptions(appkey: appKey)
        option.enableConsoleLog = false
        option.isAutoLogin = false
        
        AgoraChatClient.shared().initializeSDK(with: option)
        AgoraChatClient.shared().add(self,
                                     delegateQueue: nil)
        AgoraChatClient.shared().chatManager.add(self,
                                                 delegateQueue: nil)
        AgoraChatClient.shared().roomManager.add(self,
                                                 delegateQueue: nil)
        let extra = ["appKey": appKey,
                     "chatRoomId": chatRoomId,
                     "userId": userConfig.userName,
                     "role": "\(userConfig.role)",
                     "fcrRoomId": userConfig.fcrRoomId]
        delegate?.onEasemobLog(content: "init",
                               extra: extra.agDescription,
                               type: .info)
    }
    
    func login(token: String,
               success: EasemobSuccessCompletion?,
               failure: EasemobFailureCompletion?) {
        let lowercaseName = userConfig.userName.lowercased()
        let extra = ["token": token,
                     "lowercaseName": lowercaseName]
        delegate?.onEasemobLog(content: "start login",
                               extra: extra.agDescription,
                               type: .info)
        _login(token: token,
               lowercaseName: lowercaseName,
               success: success,
               failure: failure)
    }
    
    func join(success: EasemobSuccessCompletion?,
              failure: EasemobFailureCompletion?) {
        let extra = ["chatRoomId": chatRoomId]
        delegate?.onEasemobLog(content: "start join",
                               extra: extra.agDescription,
                               type: .info)
        _join(success: success,
              failure: failure)
    }
    
    func logout() {
        delegate?.onEasemobLog(content: "logout",
                               extra: nil,
                               type: .info)
        
        AgoraChatClient.shared().roomManager.leaveChatroom(chatRoomId,
                                                           completion: nil)
        AgoraChatClient.shared().removeDelegate(self)
        AgoraChatClient.shared().chatManager.remove(self)
        AgoraChatClient.shared().roomManager.remove(self)
        AgoraChatClient.shared().logout(false)
    }
    
    func sendImageMessageData(_ data: Data?) {
        let imageBody = AgoraChatImageMessageBody(data: data,
                                                  displayName: "image")
        let ext = messageExt()
        let message = AgoraChatMessage(conversationID: chatRoomId,
                                       from: userConfig.userName,
                                       to: chatRoomId,
                                       body: imageBody,
                                       ext: ext)
        message.chatType = .chatRoom
        
        let extra = ["chatRoomId": chatRoomId,
                     "from": userConfig.userName,
                     "to": chatRoomId,]
        delegate?.onEasemobLog(content: "send image message",
                               extra: extra.agDescription,
                               type: .info)
        AgoraChatClient.shared().chatManager.send(message,
                                                  progress: nil) { [weak self] (chatMessage, chatError) in
            guard let `self` = self else {
                return
            }
            guard chatError == nil else {
                self.delegate?.didOccurError(type: .sendFailed(chatError!.code.rawValue))
                return
            }
            guard let message = chatMessage else {
                return
            }
            self.delegate?.didSendMessages(list: [message])
        }
    }
    
    func sendTextMessage(_ text: String) {
        guard text.count > 0 else {
            return
        }
        let textBody = AgoraChatTextMessageBody(text: text)
        let ext = messageExt()
        let message = AgoraChatMessage(conversationID: chatRoomId,
                                       from: userConfig.userName,
                                       to: chatRoomId,
                                       body: textBody,
                                       ext: ext)
        message.chatType = .chatRoom
        let extra = ["chatRoomId": chatRoomId,
                     "from": userConfig.userName,
                     "to": chatRoomId,
                     "text":text]
        delegate?.onEasemobLog(content: "send text message",
                               extra: extra.agDescription,
                               type: .info)
        
        AgoraChatClient.shared().chatManager.send(message,
                                                  progress: nil) { [weak self] (chatMessage, chatError) in
            guard let `self` = self else {
                return
            }
            guard let message = chatMessage,
                  chatError == nil else {
                self.delegate?.didOccurError(type: .sendFailed(chatError!.code.rawValue))
                    return
            }
            self.delegate?.didSendMessages(list: [message])
        }
    }
    
    func sendCmdMessage(action: String) {
        guard action.count > 0 else {
            return
        }
        let extra = ["chatRoomId": chatRoomId,
                     "from": userConfig.userName,
                     "to": chatRoomId,
                     "action":action]
        delegate?.onEasemobLog(content: "send cmd message",
                               extra: extra.agDescription,
                               type: .info)
        let textBody = AgoraChatCmdMessageBody(action: action)
        let ext = messageExt()
        let message = AgoraChatMessage(conversationID: chatRoomId,
                                       from: userConfig.userName,
                                       to: chatRoomId,
                                       body: textBody,
                                       ext: ext)
        message.chatType = .chatRoom
        AgoraChatClient.shared().chatManager.send(message,
                                                  progress: nil) { [weak self] (chatMessage, chatError) in
            guard let `self` = self else {
                return
            }
            guard let message = chatMessage,
                  chatError == nil else {
                self.delegate?.didOccurError(type: .sendFailed(chatError!.code.rawValue))
                    return
            }
            self.delegate?.didReceiveMessages(list: [message])
        }
    }
    
    func muteAll(mute: Bool) {
        let extra = ["mute": "\(mute)"]
        delegate?.onEasemobLog(content: "mute all",
                               extra: extra.agDescription,
                               type: .info)
        
        if mute {
            AgoraChatClient.shared().roomManager.muteAllMembers(fromChatroom: chatRoomId) { [weak self] (chatRoom, chatError) in
                guard let `self` = self else {
                    return
                }
                guard chatError == nil else {
                    var extra = ["aError": "\(chatError!.code.rawValue)"]
 
                    self.delegate?.onEasemobLog(content: "mute all fail",
                                                extra: extra.agDescription,
                                                type: .error)
                    self.delegate?.didOccurError(type: .muteFailed(chatError!.code.rawValue))
                    return
                }
                self.sendCmdMessage(action: "setAllMute")
            }
        } else {
            AgoraChatClient.shared().roomManager.unmuteAllMembers(fromChatroom: chatRoomId) { [weak self] (chatRoom, chatError) in
                guard let `self` = self else {
                    return
                }
                guard chatError == nil else {
                    var extra = ["aError": "\(chatError!.code.rawValue)"]
                    
                    self.delegate?.onEasemobLog(content: "unmute all fail",
                                                extra: extra.agDescription,
                                                type: .error)
                    self.delegate?.didOccurError(type: .muteFailed(chatError!.code.rawValue))
                    return
                }
                self.sendCmdMessage(action: "removeAllMute")
            }
        }
    }
    
    func muteUsers(userList: [String],
                  mute: Bool) {
        let extra = ["mute": "\(mute)",
                     "userList": userList.description]
        delegate?.onEasemobLog(content: "mute users",
                               extra: extra.agDescription,
                               type: .info)
        // TODO: 移动端暂时没有该功能
    }
    
    func setAnnouncement(_ announcement: String?) {
        let extra = ["announcement": announcement ?? ""]
        delegate?.onEasemobLog(content: "set announcement",
                               extra: extra.agDescription,
                               type: .info)
        AgoraChatClient.shared().roomManager.updateChatroomAnnouncement(withId: chatRoomId,
                                                                        announcement: announcement) { [weak self] (chatRoom,chatError) in
            guard let error = chatError else {
                return
            }
            let extra = ["announcement": announcement ?? "",
                         "errorCode": "\(error.code)"]
            self?.delegate?.onEasemobLog(content: "set announcement error",
                                         extra: extra.agDescription,
                                         type: .error)
        }
    }
    
    func getAllMutedState(success: EasemobMuteStateCompletion?,
                          failure: EasemobFailureCompletion?) {
        let extra = ["chatRoomId": chatRoomId]
        delegate?.onEasemobLog(content: "get chatroom specification",
                               extra: extra.agDescription,
                               type: .info)
        AgoraChatClient.shared().roomManager.getChatroomSpecificationFromServer(withId: chatRoomId) { [weak self] (chatRoom, chatError) in
            guard let `self` = self else {
                return
            }
            guard chatError == nil else {
                var extra = ["aError": "\(chatError!.code.rawValue)"]
                
                self.delegate?.onEasemobLog(content: "get chatroom specification fail",
                                            extra: extra.agDescription,
                                            type: .error)
                self.delegate?.didOccurError(type: .fetchError(chatError!.code.rawValue))
                return
            }
            guard let room = chatRoom else {
                return
            }
            
            let isMuteAllMembers = room.isMuteAllMembers
            let extra = ["isMuteAllMembers": isMuteAllMembers ? 1 : 0]
            self.delegate?.onEasemobLog(content: "chatroom specification",
                                        extra: extra.agDescription,
                                        type: .info)
            
            // MARK: 此处必须重新为chatRoom赋值,再获取isMuteAllMembers，否则聊天室内信息可能不对
            self.chatRoom = room
            success?(room.isMuteAllMembers)
        }
    }
    
    func getLocalMutedState(success: EasemobMuteStateCompletion?,
                          failure: EasemobFailureCompletion?) {
        let extra = ["chatRoomId": chatRoomId]
        delegate?.onEasemobLog(content: "get local mute state",
                               extra: extra.agDescription,
                               type: .info)
        AgoraChatClient.shared().roomManager.isMemberInWhiteListFromServer(withChatroomId: chatRoomId) { [weak self] (inWhiteList,chatError)  in
            guard let `self` = self else {
                return
            }
            guard chatError == nil else {
                var extra = ["aError": "\(chatError!.code.rawValue)"]
                
                self.delegate?.onEasemobLog(content: "get local mute state fail",
                                            extra: extra.agDescription,
                                            type: .error)
                failure?(.fetchError(chatError!.code.rawValue))
                return
            }
            let localMuted = inWhiteList
            let extra = ["localMuted": localMuted ? 1 : 0]
            self.delegate?.onEasemobLog(content: "local mute state",
                                        extra: extra.agDescription,
                                        type: .info)
            success?(localMuted)
        }
    }
    
    func getAnnouncement(success: EasemobStringCompletion?,
                         failure: EasemobFailureCompletion?) {
        var extra = ["chatRoomId": chatRoomId]
        
        self.delegate?.onEasemobLog(content: "get announcement",
                                    extra: extra.agDescription,
                                    type: .info)
        AgoraChatClient.shared().roomManager.getChatroomAnnouncement(withId: chatRoomId) { [weak self] (announcement,chatError)  in
            guard let `self` = self else {
                return
            }
            guard chatError == nil else {
                var extra = ["aError": "\(chatError!.code.rawValue)"]
                
                self.delegate?.onEasemobLog(content: "get announcement fail",
                                            extra: extra.agDescription,
                                            type: .error)
                failure?(.fetchError(chatError!.code.rawValue))
                return
            }
            let extra = ["announcement": announcement ?? ""]
            self.delegate?.onEasemobLog(content: "announcement",
                                        extra: extra.agDescription,
                                        type: .info)
            success?(announcement)
        }
    }
    
    func getHistoryMessages(success: EasemobMessageListCompletion?,
                            failure: EasemobFailureCompletion?) {
        var extra = ["chatRoomId": chatRoomId]
        
        self.delegate?.onEasemobLog(content: "get history messages",
                                    extra: extra.agDescription,
                                    type: .info)
        AgoraChatClient.shared().chatManager.asyncFetchHistoryMessages(fromServer: chatRoomId,
                                                                       conversationType: .chatRoom,
                                                                       startMessageId: "",
                                                                       pageSize: 50) { [weak self] (result,chatError) in
            guard let `self` = self else {
                return
            }
            guard chatError == nil else {
                var extra = ["aError": "\(chatError!.code.rawValue)"]
                
                self.delegate?.onEasemobLog(content: "get history messages fail",
                                            extra: extra.agDescription,
                                            type: .error)
                failure?(.fetchError(chatError!.code.rawValue))
                return
            }
            guard let list = result?.list as? [AgoraChatMessage],
                  list.count > 0 else {
                success?(nil)
                return
            }
            let messageList = list.filter({return ($0.body.type == .text || $0.body.type == .image || $0.body.type == .cmd)})
            guard let last = messageList.last else {
                success?(nil)
                return
            }
            self.latestMessageId = last.messageId
            success?(messageList)
        }
    }
}

// MARK: - private
private extension AgoraChatEasemob {
    func _login(token: String,
                lowercaseName: String,
                success: EasemobSuccessCompletion?,
                failure: EasemobFailureCompletion?) {
        AgoraChatClient.shared().login(withUsername: lowercaseName,
                                       token: token) { [weak self] (userName, aLoginError) in
            guard let `self` = self else {
                return
            }
            guard let loginError = aLoginError,
                  loginError.code != .userAlreadyLoginSame else {
                self.retryCount = 0
                self.delegate?.onEasemobLog(content: "login success",
                                            extra: nil,
                                            type: .info)
                self.updateLocalUserInfo()
                success?()
                return
            }
            switch loginError.code {
            case .userNotFound:
                AgoraChatClient.shared().register(withUsername: self.userConfig.userName,
                                                  password: self.userConfig.password) { (userName, chatError) in
                    if let chatError = chatError {
                        self.retryCount = 0
                        let extra = ["userId":self.userConfig.userName,
                                     "password":self.userConfig.password,
                                     "code": "\(chatError.code.rawValue)"]
                        self.delegate?.onEasemobLog(content: "register fail",
                                                    extra: extra.agDescription,
                                                    type: .error)
                        failure?(.loginFailed)
                        return
                    }
                    self.delegate?.onEasemobLog(content: "register success",
                                                extra: nil,
                                                type: .info)
                    self._login(token: token,
                                lowercaseName: lowercaseName,
                                success: success,
                                failure: failure)
                }
            default:
                guard self.retryCount < self.maxRetryCount else {
                    self.retryCount = 0
                    failure?(.loginFailed)
                    return
                }
                self.retryCount += 1
                self._login(token: token,
                            lowercaseName: lowercaseName,
                            success: success,
                            failure: failure)
            }
        }
    }
    
    func _join(success: EasemobSuccessCompletion?,
               failure: EasemobFailureCompletion?) {
        AgoraChatClient.shared().roomManager.joinChatroom(chatRoomId) { [weak self] (chatRoom, chatError) in
            guard let `self` = self else {
                return
            }
            guard let `chatError` = chatError else {
                self.chatRoom = chatRoom
                self.retryCount = 0
                self.delegate?.onEasemobLog(content: "join success",
                                            extra: nil,
                                            type: .info)
                success?()
                return
            }
            
            guard self.retryCount < self.maxRetryCount else {
                self.retryCount = 0
                
                let extra = ["chatRoomId":self.chatRoomId,
                             "code": "\(chatError.code.rawValue)"]
                self.delegate?.onEasemobLog(content: "join fail",
                                            extra: extra.agDescription,
                                            type: .error)
                failure?(.joinFailed)
                return
            }
            
            self.retryCount += 1
            self._join(success: success,
                       failure: failure)
        }
    }
    
    func updateLocalUserInfo() {
        let userInfo = AgoraChatUserInfo()
        userInfo.nickname = userConfig.nickName
        let extDic = ["role": userConfig.role]
        
        if let data = extDic.jsonData() {
            let extString = String(data: data,
                                   encoding: .utf8)
            userInfo.ext = extString
        }
        
        if let avatarUrl = userConfig.avatarurl {
            userInfo.avatarUrl = avatarUrl
        }
        AgoraChatClient.shared().userInfoManager.updateOwn(userInfo) { [weak self] (chatUserInfo, chatError) in
            guard let `self` = self else {
                return
            }
            guard let `chatError` = chatError else {
                let extra = ["ext": userInfo.ext ?? ""]
                self.delegate?.onEasemobLog(content: "update user info success",
                                            extra: extra.agDescription,
                                            type: .info)
                return
            }
            
            let extra = ["ext": userInfo.ext ?? "",
                         "code": "\(chatError.code.rawValue)"]
            self.delegate?.onEasemobLog(content: "update user info fail",
                                        extra: extra.agDescription,
                                        type: .error)
            self.delegate?.didOccurError(type: .updateUserInfo)
        }
    }
    
    func messageExt() -> [String: Any] {
        var ext: [String : Any] = ["msgtype": 0,
                                   "role": userConfig.role,
                                   "nickName": userConfig.nickName,
                                   "roomUuid": userConfig.fcrRoomId]
        ext["avatarUrl"] = userConfig.avatarurl
        return ext
    }
}

// MARK: - Easemob Delegate
extension AgoraChatEasemob: AgoraChatClientDelegate,
                            AgoraChatManagerDelegate,
                            AgoraChatroomManagerDelegate {
    // MARK: AgoraChatClientDelegate
    func connectionStateDidChange(_ aConnectionState: AgoraChatConnectionState) {
        delegate?.didConnectionStateChaned(aConnectionState)
        
        let extra = ["state": aConnectionState]
        delegate?.onEasemobLog(content: "connection state chaned",
                               extra: extra.agDescription,
                               type: .info)
    }
    
    func userAccountDidLoginFromOtherDevice() {
        delegate?.onEasemobLog(content: "user account did login from other device",
                                    extra: nil,
                                    type: .error)
        
        delegate?.didOccurError(type: .loginedFromRemote)
    }
    
    func userAccountDidForced(toLogout aError: AgoraChatError?) {
        delegate?.didOccurError(type: .forcedLogOut)
        
        var extra: [String: String]?
        if let error = aError {
            extra = ["aError": "\(error.code.rawValue)"]
        }
        
        delegate?.onEasemobLog(content: "user account was forced to logout",
                               extra: extra?.agDescription,
                               type: .error)
    }
    
    // MARK: AgoraChatManagerDelegate
    func messagesDidReceive(_ aMessages: [AgoraChatMessage]) {
        let extra = ["messages": aMessages.agDescription]
        delegate?.onEasemobLog(content: "receive messages",
                               extra: extra.agDescription,
                               type: .info)
        
        let list = aMessages.filter { message in
            guard message.chatType == .chatRoom,
                  message.to == chatRoomId,
                  (message.body.type == .text || message.body.type == .image) else {
                return false
            }
            return true
        }
        guard list.count > 0,
         let last = list.last else {
            return
        }
        latestMessageId = last.messageId
        delegate?.didReceiveMessages(list: list)
    }
    
    func cmdMessagesDidReceive(_ aCmdMessages: [AgoraChatMessage]) {
        let extra = ["messages": aCmdMessages.agDescription]
        delegate?.onEasemobLog(content: "easemob receive cmd messages",
                               extra: extra.agDescription,
                               type: .info)
        
        var messageList = [AgoraChatMessage]()
        for cmdMessage in aCmdMessages {
            guard let body = cmdMessage.body as? AgoraChatCmdMessageBody,
                  let type = AgoraChatEasemobCmdMessageBodyActionType(rawValue: body.action) else {
                continue
            }
            switch type {
            case .delete:
                // recall消息暂不处理
                break
            case .setAllMute:
                messageList.append(cmdMessage)
            case .removeAllMute:
                messageList.append(cmdMessage)
            case .mute:
                guard let muteUserId = cmdMessage.ext?[muteMemberKey] as? String,
                      muteUserId == userConfig.userName else {
                    continue
                }
                messageList.append(cmdMessage)
            case .unmute:
                guard let muteUserId = cmdMessage.ext?[muteMemberKey] as? String,
                      muteUserId == userConfig.userName else {
                    continue
                }
                messageList.append(cmdMessage)
            }
        }
        guard messageList.count > 0 else {
            return
        }
        delegate?.didReceiveMessages(list: messageList)
    }

    // MARK: AgoraChatroomManagerDelegate
    func chatroomWhiteListDidUpdate(_ aChatroom: AgoraChatroom,
                                    addedWhiteListMembers aMembers: [String]) {
        let extra = ["aMembers": aMembers.agDescription]
        delegate?.onEasemobLog(content: "users muted",
                               extra: extra.agDescription,
                               type: .info)
        
        guard aChatroom.chatroomId == chatRoomId,
              aMembers.count > 0,
              aMembers.contains(userConfig.userName) else {
            return
        }
        delegate?.didLocalMuteStateChanged(true)
    }
    
    func chatroomWhiteListDidUpdate(_ aChatroom: AgoraChatroom,
                                    removedWhiteListMembers aMembers: [String]) {
        let extra = ["aMembers": aMembers.agDescription]
        delegate?.onEasemobLog(content: "users unmuted",
                               extra: extra.agDescription,
                               type: .info)
        
        guard aChatroom.chatroomId == chatRoomId,
              aMembers.count > 0,
              aMembers.contains(userConfig.userName) else {
            return
        }
        delegate?.didLocalMuteStateChanged(false)
    }
    
    func chatroomAllMemberMuteChanged(_ aChatroom: AgoraChatroom,
                                      isAllMemberMuted aMuted: Bool) {
        let extra = ["muted": "\(aMuted)"]
        delegate?.onEasemobLog(content: "users all muted",
                               extra: extra.agDescription,
                               type: .info)
        guard aChatroom.chatroomId == chatRoomId else {
            return
        }
        delegate?.didAllMuteStateChanged(aMuted)
    }
    
    func chatroomAnnouncementDidUpdate(_ aChatroom: AgoraChatroom,
                                       announcement aAnnouncement: String?) {
        let extra = ["announcement": aAnnouncement ?? ""]
        delegate?.onEasemobLog(content: "announcement updated",
                               extra: extra.agDescription,
                               type: .info)
        guard aChatroom.chatroomId == chatRoomId else {
            return
        }
        delegate?.didReceiveAnnouncement(aAnnouncement)
    }
}
