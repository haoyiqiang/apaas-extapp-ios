//
//  AgoraWidgetServerAPI.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/5/6.
//

import Foundation
import Armin

public typealias SuccessCompletion = () -> ()
public typealias JsonCompletion = ([String: Any]) -> ()
public typealias FailureCompletion = (Error) -> ()

public class AgoraWidgetServerAPI:NSObject {
    private(set) var host: String
    private(set) var appId: String
    private(set) var token: String
    private(set) var roomId: String
    private(set) var userId: String
    private(set) var armin: Armin
    
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
        
    func request(event: String,
                 url: String,
                 method: ArHttpMethod,
                 header: [String: String]? = nil,
                 parameters: [String: Any]? = nil,
                 isRetry: Bool = false,
                 success: JsonCompletion? = nil,
                 failure: FailureCompletion? = nil) {
        var tHeader = ["x-agora-token": token,
                       "x-agora-uid": userId,
                       "Authorization": "agora token=\"\(token)\""]
        
        if let `header` = header {
            tHeader.merge(header) { _, new in
                new
            }
        }
        
        let event = ArRequestEvent(name: event)
        
        let requestType: ArRequestType = .http(method,
                                               url: url)
        
        let task = ArRequestTask(event: event,
                                 type: requestType,
                                 timeout: .medium,
                                 header: tHeader,
                                 parameters: parameters)
        
        let response = ArResponse.json { [weak self] (json) in
            success?(json)
        }
        
        let failureRetry: ArErrorRetryCompletion = { [weak self] (error) -> ArRetryOptions in
            failure?(error)
            return (isRetry ? .retry(after: 1) : .resign)
        }
        
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: response,
                      failRetry: failureRetry)
    }
}
