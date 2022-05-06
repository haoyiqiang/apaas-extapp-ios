//
//  AgoraWhiteBoardServerAPI.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/5/6.
//

import Foundation
import Armin

class AgoraWhiteBoardServerAPI: AgoraWidgetServerAPI {
    func getWindowAttributes(success: JsonCompletion? = nil,
                             failure: FailureCompletion? = nil) {
        let event = ArRequestEvent(name: "pop-up-quiz-submit")
        let url = host + "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/netlessBoard/windowManager"
        
        let header = ["x-agora-token": token,
                      "x-agora-uid": userId]
        
        request(event: "get-window-attributes",
                url: url,
                method: .get,
                header: header,
                isRetry: true) { (json) in
            success?(json)
        } failure: { (error) in
            failure?(error)
        }
    }
}
