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
    
    private var armin: Armin!
    
    private let baseInfo: AgoraAppBaseInfo
    private let roomId: String
    private let uid: String
    
    private lazy var coursewareDir: String = {
        let cachesFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                               .userDomainMask,
                                                               true)[0]
        let path = "\(cachesFolder)/AgoraDownload"
        if !FileManager.default.fileExists(atPath: path,
                                           isDirectory: nil) {
            try? FileManager.default.createDirectory(atPath: path,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        return path
    }()
    
    init(baseInfo: AgoraAppBaseInfo,
         roomId: String,
         uid: String) {
        self.baseInfo = baseInfo
        self.roomId = roomId
        self.uid = uid
        
        super.init()
        
        self.armin = Armin(delegate: self,
                           logTube: self)
    }
    
    func start() {
        
    }
    
    func submit(pollId: String,
                selectIndex: [Int],
                success: @escaping SuccessBlock,
                fail: @escaping FailBlock) {
        let path = "/edu/apps/\(baseInfo.agoraAppId)/v2/rooms/\(roomId)/widgets/polls/\(pollId)/users/\(uid)"
        let urlString = baseInfo.host + path
        
        let event = ArRequestEvent(name: "widget-poll-submit")
        let type = ArRequestType.http(.post,
                                      url: urlString)
        let header = ["x-agora-token" : baseInfo.token,
                      "x-agora-uid" : uid]
        let parameters: [String : Any] = ["selectIndex" : selectIndex]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: header,
                                 parameters: parameters)
        
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .data({ data in
            success()
        }), failRetry: { error in
            fail(error)
            return .resign
        })
    }
    
    func stop() {
        
    }
}

extension AgoraPollServerAPI: ArminDelegate {
    func armin(_ client: Armin,
               requestSuccess event: ArRequestEvent,
               startTime: TimeInterval,
               url: String) {
        
    }
    
    func armin(_ client: Armin,
               requestFail error: ArError,
               event: ArRequestEvent,
               url: String) {
        
    }
}

extension AgoraPollServerAPI: ArLogTube {
    func log(info: String,
             extra: String?) {
        print("[AgoraPollServerAPI] \(extra) - \(info)")
    }
    
    func log(warning: String,
             extra: String?) {
        print("[AgoraPollServerAPI] \(extra) - \(warning)")
    }
    
    func log(error: ArError,
             extra: String?) {
        print("[AgoraPollServerAPI] \(extra) - \(error.localizedDescription)")
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

