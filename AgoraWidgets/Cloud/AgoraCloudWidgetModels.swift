//
//  AgoraCloudWidgetModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/17.
//

import Foundation
// MARK: - Message
enum AgoraCloudInteractionSignal: Convertable {
    case OpenCoursewares(AgoraCloudWhiteScenesInfo)
    case CloseCloud
    
    private enum CodingKeys: CodingKey {
        case OpenCoursewares
        case CloseCloud
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .CloseCloud) {
            self = .CloseCloud
        } else if let value = try? container.decode(AgoraCloudWhiteScenesInfo.self,
                                                    forKey: .OpenCoursewares) {
            self = .OpenCoursewares(value)
        } else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "invalid data"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .CloseCloud:
            try container.encodeNil(forKey: .CloseCloud)
        case .OpenCoursewares(let x):
            try container.encode(x,
                                 forKey: .OpenCoursewares)
        }
    }
    
    func toMessageString() -> String? {
        guard let dic = self.toDictionary(),
           let str = dic.jsonString() else {
            return nil
        }
        return str
    }
}

// MARK: - VM
enum AgoraCloudCoursewareType {
    /// 公共资源
    case publicResource
    /// 我的云盘
    case privateResource
}

// MARK: - to Whiteboard
struct AgoraCloudConvertedFile: Convertable {
    public var name: String
    public var ppt: AgoraCloudPptPage
}

struct AgoraCloudWhiteScenesInfo: Convertable {
    public let resourceName: String
    public let resourceUuid: String
    public let scenes: [AgoraCloudConvertedFile]
    public let convert: Bool?
}

// MARK: - Widget
struct AgoraCloudCourseware: Convertable {
    var resourceName: String
    var resourceUuid: String
    var scenePath: String
    var resourceURL: String
    var scenes: [AgoraCloudConvertedFile]
    /// 原始文件的扩展名
    var ext: String
    /// 原始文件的大小 单位是字节
    var size: Double
    /// 原始文件的更新时间
    var updateTime: Double
    
    var convert: Bool?
    
    init(resourceName: String,
         resourceUuid: String,
         scenePath: String,
         resourceURL: String,
         scenes: [AgoraCloudConvertedFile],
         ext: String,
         size: Double,
         updateTime: Double,
         convert: Bool?) {
        self.resourceName = resourceName
        self.resourceUuid = resourceUuid
        self.scenePath = scenePath
        self.resourceURL = resourceURL
        self.scenes = scenes
        self.ext = ext
        self.size = size
        self.updateTime = updateTime
        self.convert = convert
    }
    
    init(fileItem: CloudServerApi.FileItem) {
        let scenes = fileItem.taskProgress.convertedFileList.map { conFile -> AgoraCloudConvertedFile in
            let ppt = AgoraCloudPptPage(src: conFile.ppt.src,
                                             width: conFile.ppt.width,
                                             height: conFile.ppt.height,
                                             preview: conFile.ppt.preview)
            return AgoraCloudConvertedFile(name: conFile.name,
                                           ppt: ppt)
        }
        
        self.init(resourceName: fileItem.resourceName,
                  resourceUuid: fileItem.resourceUuid,
                  scenePath: "/\(fileItem.resourceName)" ,
                  resourceURL: fileItem.url,
                  scenes: scenes,
                  ext: fileItem.ext,
                  size: fileItem.size,
                  updateTime: fileItem.updateTime,
                  convert: fileItem.convert)
    }
    
    init(publicCourseware: AgoraCloudPublicCourseware) {
        self.init(resourceName: publicCourseware.resourceName,
                  resourceUuid: publicCourseware.resourceUUID,
                  scenePath: "/\(publicCourseware.resourceName)" ,
                  resourceURL: publicCourseware.url,
                  scenes: publicCourseware.taskProgress.convertedFileList,
                  ext: publicCourseware.ext,
                  size: Double(publicCourseware.size),
                  updateTime: Double(publicCourseware.updateTime),
                  convert: publicCourseware.conversion.convert)
    }
}

struct AgoraCloudPptPage: Convertable {
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
}

// MARK: - public coursewares
struct AgoraCloudPublicCourseware: Convertable {
    let resourceUUID: String
    let resourceName: String
    let ext: String
    let size: Int64
    let url: String
    let updateTime: Int64
    let taskUUID: String
    let conversion: AgoraCloudPublicConversion
    let taskProgress: AgoraCloudTaskProgress

    enum CodingKeys: String, CodingKey {
        case resourceUUID = "resourceUuid"
        case resourceName, ext, size, url, updateTime
        case taskUUID = "taskUuid"
        case conversion, taskProgress
    }
}

struct AgoraCloudPublicConversion: Convertable {
    let type: String
    let preview: Bool
    let scale: Int64
    let outputFormat: String
    let convert: Bool?
}

struct AgoraCloudTaskProgress: Convertable {
    let status: String?
    let totalPageSize: Int64
    let convertedPageSize: Int64
    let convertedPercentage: Int64
    let currentStep: String?
    let convertedFileList: [AgoraCloudConvertedFile]
}

// MARK: - common extension
extension Array where Element == AgoraCloudPublicCourseware {
    func toConfig() -> Array<AgoraCloudCourseware> {
        var configs = Array<AgoraCloudCourseware>()
        for item in self {
            var config = AgoraCloudCourseware(publicCourseware: item)
            configs.append(config)
        }
        return configs
    }
}

extension Array where Element == AgoraCloudCourseware {
    func toCellInfos() -> Array<AgoraCloudCellInfo> {
        var cellInfos = [AgoraCloudCellInfo]()
        for courseware in self {
            let info = AgoraCloudCellInfo(courseware: courseware)
            cellInfos.append(info)
        }
        return cellInfos
    }
}


extension String {
    func toCloudSignal() -> AgoraCloudInteractionSignal? {
        guard let dic = self.toDic(),
              let signal = dic.toObj(AgoraCloudInteractionSignal.self) else {
                  return nil
              }
        
        return signal
    }
}

