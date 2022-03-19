//
//  CloudServerApi.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import Armin

class AgoraCloudServerAPI: NSObject {
    typealias FailBlock = (Error) -> ()
    typealias SuccessBlock<T: Decodable> = (T) -> ()
    
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
                               resourceName: String? = nil,
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
        var parameters: [String : Any] = ["pageNo" : pageNo,
                                          "pageSize" : pageSize]
        if let resourceStr = resourceName {
            parameters["resourceName"] = resourceStr
        }
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: header,
                                 parameters: parameters)
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .json({[weak self] dic in
                        self?.currentRequesting = false
                        if let dataDic = dic["data"] as? [String: Any],
                           let source = dataDic.toObj(SourceDataInUserPage.self){
                            success(source)
                        } else {
                            fail(NSError(domain: "decode", code: -1))
                        }
                      })) {[weak self] error in
            self?.currentRequesting = false
            fail(error)
            return .resign
        }
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
    struct SourceData: Convertable {
        let total: Int
        let list: [FileItem]
        let nextId: Int?
        let count: Int
    }
    
    struct SourceDataInUserPage: Convertable {
        let total: Int
        let list: [FileItem]
        let pageNo: Int
        let pageSize: Int
        let pages: Int
    }
    
    struct FileItem: Convertable {
        let resourceUuid: String
        let resourceName: String
        let ext: String
        let size: Double
        let url: String
        let tags: [String]?
        let updateTime: TimeInterval
        let taskUuid: String?
        let taskToken: String?
        let taskProgress: AgoraCloudTaskProgress?
        /// 是否转换
        let convert: Bool?
        let conversion: Conversion?
    }
    
    struct Conversion: Convertable {
        let type: String
        let preview: Bool
        let scale: Double
        let canvasVersion: Bool
        let outputFormat: String
        let convert: Bool?
    }
}
