//
//  AgoraChatServerAPI.swift
//  AgoraWidgets
//
//  Created by lixiaoming on 2022/6/8.
//

import UIKit
import Armin;

class AgoraChatLogTube:NSObject,ArLogTube
{
    public func log(info: String, extra: String?) {
        print("[AgoraChatLogTube] info:\(info) extra:\(extra)");
    }
    
    public func log(warning: String, extra: String?) {
        print("[AgoraChatLogTube] warning:\(warning) extra:\(extra)");
    }
    
    public func log(error: ArError, extra: String?) {
        print("[AgoraChatLogTube] error:\(error.localizedDescription) extra:\(extra)");
    }
}

public class AgoraChatServerAPI: AgoraWidgetServerAPI {
    @objc public static func createInstance(inputhost:String,inputappId:String,inputtoken:String,inputroomId:String,inputuserId:String) -> AgoraChatServerAPI {
        let acLogTube:AgoraChatLogTube = AgoraChatLogTube.init();
        return AgoraChatServerAPI.init(host: inputhost, appId: inputappId, token: inputtoken, roomId: inputroomId, userId: inputuserId, logTube: acLogTube)
    }
    @objc public func fetchHXToken(_ username: String,
                      success: JsonCompletion? = nil,
                      failure: FailureCompletion? = nil) {
        
        let url = host + "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/easemobIM/users/\(userId)/token"
        
        let header = ["x-agora-token": token,
                      "x-agora-uid": userId]
        
        request(event: "fetch-hx-token",
                url: url,
                method: .get,
                header: header,
                isRetry: true,
                success: success,
                failure: failure)
        }
}
