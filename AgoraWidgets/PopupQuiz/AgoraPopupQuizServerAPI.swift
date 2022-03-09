//
//  AgoraPopupQuizServerAPI.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/7.
//

import Foundation
import Armin
import UIKit

class AgoraPopupQuizServerAPI: NSObject {
    private var host: String
    private var appId: String
    private var token: String
    private var roomId: String
    private var userId: String
    private var armin: Armin
    
    init(host: String,
         appId: String,
         token: String,
         roomId: String,
         userId: String,
         logTube: ArLogTube) {
        self.host = host
        self.appId = appId
        self.token = token
        self.roomId = roomId
        self.userId = userId
        self.armin = Armin(delegate: nil,
                           logTube: logTube)
    }
    
    func submitAnswer(_ answerList: [String],
                      selectorId: String,
                      success: (() -> Void)?,
                      failure: ((Error) -> Void)? = nil) {
        let event = ArRequestEvent(name: "pop-up-quiz-submit")
        let url = host + "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/popupQuizs/\(selectorId)/users/\(userId)"
        let parameters = ["selectedItems": answerList]
        
        let task = ArRequestTask(event: event,
                                 type: .http(.put, url: url),
                                 timeout: .medium,
                                 parameters: parameters)
        
        armin.request(task: task,
                      success: ArResponse.blank({ [weak self] in
                        success?()
        })) { (error) -> ArRetryOptions in
            failure?(error)
            return .resign
        }
    }
}
