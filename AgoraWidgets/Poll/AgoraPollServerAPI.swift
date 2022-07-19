//
//  AgoraPollServerAPI.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/5.
//


import Armin

class AgoraPollServerAPI: AgoraWidgetServerAPI {
    func submit(pollId: String,
                selectList: [Int],
                success: SuccessCompletion? = nil,
                failure: FailureCompletion? = nil) {
        let path = "/edu/apps/\(appId)/v2/rooms/\(roomId)/widgets/polls/\(pollId)/users/\(userId)"
        let urlString = host + path
        
        let parameters: [String: Any] = ["selectIndex": selectList]
       
        
        request(event: "widget-poll-submit",
                url: urlString,
                method: .post,
                parameters: parameters) { _ in
            success?()
        } failure: { error in
            failure?(error)
        }
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
}

extension AgoraPollServerAPI {
    struct Resp<T: Decodable>: Decodable {
        let msg: String
        let code: Int
        let ts: Double
        let data: T
    }
    
    struct SourceData: Decodable {
        let total: Int
        let list: [FileItem]
        let nextId: Int?
        let count: Int
    }
    
    struct SourceDataInUserPage: Decodable {
        let total: Int
        let list: [FileItem]
        let pageNo: Int
        let pageSize: Int
        let pages: Int
    }
    
    struct FileItem: Decodable {
        let resourceUuid: String
        let resourceName: String
        let ext: String
        let size: Double
        let url: String
        let tags: [String]?
        let updateTime: TimeInterval
        /// 是否转换
        let convert: Bool?
        let taskUuid: String
        let taskToken: String
        let taskProgress: AgoraCloudTaskProgress
    }
}

