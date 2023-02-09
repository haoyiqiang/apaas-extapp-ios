//
//  CloudServerApi.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import Armin

class AgoraCloudServerAPI: AgoraWidgetServerAPI {
    typealias SuccessBlock<T: Decodable> = (T) -> ()
    
    func requestResourceInUser(pageNo: Int,
                               pageSize: Int,
                               resourceName: String? = nil,
                               success: @escaping SuccessBlock<ServerSourceData>,
                               failure: @escaping FailureCompletion) {
        let path = "/edu/apps/\(appId)/v3/users/\(userId)/resources/page"
        let urlString = host + path
        
        var parameters: [String : Any] = ["pageNo" : pageNo,
                                          "pageSize" : pageSize]
        
        if let `resourceName` = resourceName {
            parameters["resourceName"] = resourceName
        }
        
        request(event: "cloud-page",
                url: urlString,
                method: .get,
                parameters: parameters) { json in
            if let dataDic = json["data"] as? [String: Any],
               let source = dataDic.toObject(ServerSourceData.self) {
                success(source)
            } else {
                failure(NSError(domain: "decode",
                                code: -1))
            }
        } failure: { error in
            failure(error)
        }
    }
}
