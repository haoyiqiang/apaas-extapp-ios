//
//  AgoraChatRtmModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/26.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func rtmMessageToMessageViewType(localUserId: String) -> AgoraChatMessageViewType? {
        guard let content = self["content"] as? String,
              let userDict = self["user"] as? [String: Any],
              let name = userDict["userName"] as? String,
              let role = userDict["userRole"] as? String,
              let userId = userDict["userUuid"] as? String else {
            return nil
        }
        let isLocal = (userId == localUserId)
        let model = AgoraChatTextMessageModel(isLocal: isLocal,
                                              userRole: role.toRoleName(),
                                              userName: name,
                                              avatar: nil,
                                              text: content)
        let type = AgoraChatMessageViewType.text(model)
        return type
    }
    
    func rtmHistoryMessageToMessageViewType(localUserId: String) -> AgoraChatMessageViewType? {
        guard let content = self["message"] as? String,
              let userDict = self["fromUser"] as? [String: Any],
              let name = userDict["userName"] as? String,
              let role = userDict["role"] as? String,
              let userId = userDict["userUuid"] as? String else {
            return nil
        }
        let isLocal = (userId == localUserId)
        let model = AgoraChatTextMessageModel(isLocal: isLocal,
                                              userRole: role.toRoleName(),
                                              userName: name,
                                              avatar: nil,
                                              text: content)
        let type = AgoraChatMessageViewType.text(model)
        return type
    }
}
