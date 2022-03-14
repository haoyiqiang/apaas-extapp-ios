//
//  AgoraPollServerAPI.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/5.
//


import Armin

class AgoraPollServerAPI: NSObject {
    typealias FailBlock = (Error) -> ()
    typealias SuccessBlock = () -> ()
    
    private var armin: Armin
    
    private let baseInfo: AgoraAppBaseInfo
    private let roomId: String
    private let uid: String
    
    init(baseInfo: AgoraAppBaseInfo,
         roomId: String,
         uid: String,
         logTube: ArLogTube) {
        self.baseInfo = baseInfo
        self.roomId = roomId
        self.uid = uid
        
        self.armin = Armin(delegate: nil,
                           logTube: logTube)
        
        super.init()
    }
    
    func submit(pollId: String,
                selectList: [Int],
                success: SuccessBlock? = nil,
                fail: FailBlock? = nil) {
        let path = "/edu/apps/\(baseInfo.agoraAppId)/v2/rooms/\(roomId)/widgets/polls/\(pollId)/users/\(uid)"
        let urlString = baseInfo.host + path
        
        let event = ArRequestEvent(name: "widget-poll-submit")
        let type = ArRequestType.http(.post,
                                      url: urlString)
        let header = ["x-agora-token" : baseInfo.token,
                      "x-agora-uid" : uid]
        let parameters: [String : Any] = ["selectIndex" : selectList]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: header,
                                 parameters: parameters)
        
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .data({ data in
            success?()
        }), failRetry: { error in
            fail?(error)
            return .resign
        })
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

