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
                               success: @escaping SuccessBlock<SourceData>,
                               failure: @escaping FailureCompletion) {
        guard !currentRequesting else {
            return
        }
        
        currentRequesting = true
        
        let path = "/edu/apps/\(appId)/v3/users/\(userId)/resources/page"
        let urlString = host + path
        
        let event = ArRequestEvent(name: "CloudServerApi")
        let type = ArRequestType.http(.get,
                                      url: urlString)
       
        
        var parameters: [String : Any] = ["pageNo" : pageNo,
                                          "pageSize" : pageSize]
        
        if let `resourceName` = resourceName {
            parameters["resourceName"] = resourceName
        }
        
        request(event: "cloud-page",
                url: path,
                method: .get,
                parameters: parameters) { [weak self] json in
            self?.currentRequesting = false
            if let dataDic = json["data"] as? [String: Any],
               let source = dataDic.toObj(SourceData.self){
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

extension AgoraCloudServerAPI {
    struct SourceData: Convertable {
        let total: Int
        let list: [FileItem]
        let pageNo: Int
        let pageSize: Int
        let pages: Int
    }
    
    struct FileItem: Convertable {
        // 资源Uuid
        let resourceUuid: String!
        // 资源名称
        let resourceName: String!
        // 扩展名
        let ext: String!
        // 文件大小
        let size: Double!
        // 文件路径
        let url: String!
        // 更新时间
        let updateTime: Int64!
        // tag列表
        let tags: [String]?
        // 资源父级Uuid (当前文件/文件夹的父级目录的resouceUuid，如果当前目录为根目录则为root)
        let parentResourceUuid: String?
        // 文件/文件夹 (如果是文件则为1，如果是文件夹则为0)
        let type: Int?
        // 【需要转换的文件才有】文件转换状态（未转换（0），转换中（1），转换完成（2））
        let convertType: Int?
        
        // 【需要转换的文件才有】
        let taskUuid: String?
        // 【需要转换的文件才有】
        let taskToken: String?
        // 【需要转换的文件才有】
        let taskProgress: AgoraCloudTaskProgress?
        // 【需要转换的文件才有】需要转换的文件才有
        let conversion: Conversion?
    }
    
    struct Conversion: Convertable {
        let type: String
        let preview: Bool
        let scale: Float
        let canvasVersion: Bool?
        let outputFormat: String
    }
}
