//
//  AgoraPopupQuizServerAPI.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/7.
//

import Foundation
import Armin

class AgoraPopupQuizServerAPI: AgoraWidgetServerAPI {
    func submitAnswer(_ answerList: [String],
                      selectorId: String,
                      success: SuccessCompletion? = nil,
                      failure: FailureCompletion? = nil) {
        let event = ArRequestEvent(name: "pop-up-quiz-submit")
        let url = host + "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/popupQuizs/\(selectorId)/users/\(userId)"
        let parameters = ["selectedItems": answerList]
        
        let header = ["x-agora-token": token,
                      "x-agora-uid": userId]
        
        request(event: "pop-up-quiz-submit",
                url: url,
                method: .put,
                header: header,
                parameters: parameters) { _ in
            success?()
        } failure: { (error) in
            failure?(error)
        }
    }
}
