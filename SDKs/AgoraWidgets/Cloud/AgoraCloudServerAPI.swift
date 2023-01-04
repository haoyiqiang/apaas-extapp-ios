//
//  CloudServerApi.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import Armin

class AgoraCloudServerAPI: AgoraWidgetServerAPI {
    typealias SuccessBlock<T: Decodable> = (T) -> ()
    
    private var currentRequesting: Bool = false
    
    func requestResourceInUser(pageNo: Int,
                               pageSize: Int,
                               resourceName: String? = nil,
                               success: @escaping SuccessBlock<ServerSourceData>,
                               failure: @escaping FailureCompletion) {
        guard !currentRequesting else {
            return
        }
        
        currentRequesting = true
        
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
                parameters: parameters) { [weak self] json in
            self?.currentRequesting = false
            if let dataDic = json["data"] as? [String: Any],
               let source = dataDic.toObj(ServerSourceData.self){
                success(source)
            } else {
                failure(NSError(domain: "decode",
                                code: -1))
            }
        } failure: { [weak self] error in
            self?.currentRequesting = false
            failure(error)
        }
    }
}
