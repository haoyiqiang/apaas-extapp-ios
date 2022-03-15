//
//  CloudServerApi.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import Armin

class AgoraCloudServerAPI: NSObject {
    typealias FailBlock = (Error) -> ()
    typealias SuccessBlock<T: Decodable> = (Resp<T>) -> ()
    
    private var armin: Armin!
    
    private let baseInfo: AgoraAppBaseInfo
    private let uid: String
    
    private var currentRequesting: Bool = false
    
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
         uid: String) {
        self.baseInfo = baseInfo
        self.uid = uid
        
        super.init()
        
        self.armin = Armin(delegate: self,
                           logTube: self)
    }

    func requestResourceInUser(pageNo: Int,
                               pageSize: Int,
                               success: @escaping SuccessBlock<SourceDataInUserPage>,
                               fail: @escaping FailBlock) {
        guard !currentRequesting else {
            return
        }
        currentRequesting = true
        
        let path = "/edu/apps/\(baseInfo.agoraAppId)/v2/users/\(uid)/resources/page"
        let urlString = baseInfo.host + path
        
        let event = ArRequestEvent(name: "CloudServerApi")
        let type = ArRequestType.http(.get,
                                      url: urlString)
        let header = ["x-agora-token" : baseInfo.token,
                      "x-agora-uid" : uid]
        let parameters: [String : Any] = ["pageNo" : pageNo,
                                          "pageSize" : pageSize,
                                          "orderBy" : "updateTime"]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: header,
                                 parameters: parameters)
        
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .data({ [weak self] data in
            self?.currentRequesting = false
            let decoder = JSONDecoder()
            do {
                let resp = try decoder.decode(Resp<SourceDataInUserPage>.self,
                                              from: data)
                success(resp)
            } catch let e {
                print(e)
                fail(e)
            }
        }), failRetry: {[weak self] error in
            self?.currentRequesting = false
            fail(error)
            return .resign
        })
    }
}

extension AgoraCloudServerAPI: ArminDelegate {
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

extension AgoraCloudServerAPI: ArLogTube {
    func log(info: String,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(info)")
    }
    
    func log(warning: String,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(warning)")
    }
    
    func log(error: ArError,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(error.localizedDescription)")
    }
}

extension AgoraCloudServerAPI {
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
