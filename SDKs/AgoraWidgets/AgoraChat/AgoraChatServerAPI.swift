//
//  AgoraChatServerAPI.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import Foundation

class AgoraChatServerAPI: AgoraWidgetServerAPI {
    // easemobIM
    func fetchEasemobIMToken(success: JsonCompletion? = nil,
                             failure: FailureCompletion? = nil) {
        let url = host + "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/easemobIM/users/\(userId)/token"
        
        request(event: "fetch-hx-token",
                url: url,
                method: .get,
                isRetry: true,
                success: success,
                failure: failure)
    }
    
    // rtmIM
    func fetchHistoryMessage(success: JsonListCompletion? = nil,
                             failure: FailureCompletion? = nil) {
        let url = "\(host)/edu/apps/\(appId)/v2/rooms/\(roomId)/chat/messages"
        let header = ["Content-Type": "application/json"]
        let params: [String : Any] = [
            "sort": 1,
        ]
        request(event: "rtm-history-message",
                url: url,
                method: .get,
                header: header,
                parameters: params) { [weak self] (json) in
            if let data = json["data"] as? [String: Any],
               let list = data["list"] as? [Dictionary<String, Any>] {
                success?(list)
            }
        } failure: { error in
            failure?(error)
        }
    }
    
    func sendMessage(_ message: String,
                     success: SuccessCompletion? = nil,
                     failure: FailureCompletion? = nil) {
        let url = "\(host)/edu/apps/\(appId)/v2/rooms/\(roomId)/from/\(userId)/chat"
        let header = ["Content-Type": "application/json"]
        let params: [String : Any] = [
            "message": message,
            "type": 1
        ]
        
        request(event: "rtm-send-message",
                url: url,
                method: .post,
                header: header,
                parameters: params) { [weak self] (json) in
            guard let data = json["data"] as? [String: Any],
               let message = data["message"] as? String,
               let timestamp = data["sendTime"] as? Int else {
                return
            }
            success?()
        } failure: { error in
            failure?(error)
        }

    }
}
