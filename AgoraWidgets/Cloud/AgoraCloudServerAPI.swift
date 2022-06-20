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
    
    private let baseInfo: AgoraWidgetRequestKeys
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
    
    init(baseInfo: AgoraWidgetRequestKeys,
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
                               success: @escaping SuccessBlock<SourceData>,
                               fail: @escaping FailBlock) {
        guard !currentRequesting else {
            return
        }
        currentRequesting = true
        
        let path = "/edu/apps/\(baseInfo.agoraAppId)/v3/users/\(uid)/resources/page"
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
                           let source = dataDic.toObj(SourceData.self){
                            success(source)
                        } else {
                            fail(NSError(domain: "decode",
                                         code: -1))
                        }
                      })) { [weak self] error in
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
        // 【需要转换的文件才有】,是否转换
//        let convert: Bool?
        // 【需要转换的文件才有】需要转换的文件才有
        let conversion: Conversion?
    }
    
    struct Conversion: Convertable {
        let type: String
        let preview: Bool
        let scale: Double
        let canvasVersion: Bool?
        let outputFormat: String
//        let convert: Bool?
    }
}
