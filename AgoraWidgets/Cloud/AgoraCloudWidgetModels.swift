//
//  AgoraCloudWidgetModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/17.
//

import Foundation

// MARK: - Message
enum AgoraCloudInteractionSignal: Convertable {
    case openCourseware(AgoraCloudWhiteScenesInfo)
    case closeCloud
    
    private enum CodingKeys: CodingKey {
        case openCourseware
        case CloseCloud
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .CloseCloud) {
            self = .closeCloud
        } else if let value = try? container.decode(AgoraCloudWhiteScenesInfo.self,
                                                    forKey: .openCourseware) {
            self = .openCourseware(value)
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
        case .closeCloud:
            try container.encodeNil(forKey: .CloseCloud)
        case .openCourseware(let x):
            try container.encode(x,
                                 forKey: .openCourseware)
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
    
    var uiType: AgoraCloudUIFileType {
        switch self {
        case .publicResource:  return .uiPublic
        case .privateResource: return .uiPrivate
        }
    }
}

// MARK: - to Whiteboard
struct AgoraCloudConvertedFile: Convertable {
    public var name: String
    public var ppt: AgoraCloudPptPage
}

struct AgoraCloudWhiteScenesInfo: Convertable {
    public let resourceName: String
    public let resourceUuid: String
    public let resourceUrl: String
    public let ext: String
    public let scenes: [AgoraCloudConvertedFile]?
    public let convert: Bool?
}

// MARK: - Widget
struct AgoraCloudCourseware: Convertable {
    var resourceName: String
    var resourceUuid: String
    var resourceURL: String
    /// ppt才有
    var scenes: [AgoraCloudConvertedFile]?
    /// 原始文件的扩展名
    var ext: String
    /// 原始文件的大小 单位是字节
    var size: Double
    /// 原始文件的更新时间
    var updateTime: Int64
    
    var convert: Bool?
    
    init(resourceName: String,
         resourceUuid: String,
         resourceURL: String,
         scenes: [AgoraCloudConvertedFile]?,
         ext: String,
         size: Double,
         updateTime: Int64,
         convert: Bool?) {
        self.resourceName = resourceName
        self.resourceUuid = resourceUuid
        self.resourceURL = resourceURL
        self.scenes = scenes
        self.ext = ext
        self.size = size
        self.updateTime = updateTime
        self.convert = convert
    }
    
    init(fileItem: AgoraCloudServerAPI.FileItem) {
        let scenes = fileItem.taskProgress?.convertedFileList.map { conFile -> AgoraCloudConvertedFile in
            let ppt = AgoraCloudPptPage(src: conFile.ppt.src,
                                             width: conFile.ppt.width,
                                             height: conFile.ppt.height,
                                             preview: conFile.ppt.preview)
            return AgoraCloudConvertedFile(name: conFile.name,
                                           ppt: ppt)
        }
        
        self.init(resourceName: fileItem.resourceName,
                  resourceUuid: fileItem.resourceUuid,
                  resourceURL: fileItem.url,
                  scenes: scenes,
                  ext: fileItem.ext,
                  size: fileItem.size,
                  updateTime: fileItem.updateTime,
                  convert: fileItem.conversion?.canvasVersion ?? false)
    }
    
    init(publicCourseware: AgoraCloudPublicCourseware) {
        self.init(resourceName: publicCourseware.resourceName,
                  resourceUuid: publicCourseware.resourceUUID,
                  resourceURL: publicCourseware.url,
                  scenes: publicCourseware.taskProgress.convertedFileList,
                  ext: publicCourseware.ext,
                  size: Double(publicCourseware.size),
                  updateTime: publicCourseware.updateTime,
                  convert: publicCourseware.conversion.canvasVersion)
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
    let scale: Float
    let outputFormat: String
    let canvasVersion: Bool?
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

// MARK: Data To UI Model
extension Array where Element == AgoraCloudCourseware {
    func toCellInfos() -> Array<AgoraCloudCellInfo> {
        var cellInfos = [AgoraCloudCellInfo]()
        for courseware in self {
            let info = AgoraCloudCellInfo(ext: courseware.ext,
                                          name: courseware.resourceName)
            cellInfos.append(info)
        }
        return cellInfos
    }
}

// MARK: - to Signal
extension String {
    func toCloudSignal() -> AgoraCloudInteractionSignal? {
        guard let dic = self.toDic(),
              let signal = dic.toObj(AgoraCloudInteractionSignal.self) else {
                  return nil
              }
        
        return signal
    }
}

// MARK: - UI
enum AgoraCloudUIFileType {
    case uiPublic, uiPrivate
    
    var dataType: AgoraCloudCoursewareType {
        switch self {
        case .uiPublic:
            return .publicResource
        case .uiPrivate:
            return .privateResource
        }
    }
}

class AgoraCloudCellInfo: NSObject {
    var image: UIImage?
    let name: String
    
    init(ext: String,
         name: String) {
        self.name = name
        super.init()
        
        self.image =  ext.cloudTypeImage()
    }
}

fileprivate extension String {
    func cloudTypeImage() -> UIImage? {
        let config = UIConfig.cloudStorage.cell.image
        switch self {
        case "pptx", "ppt", "pptm":
            return config.pptImage
        case "docx", "doc":
            return config.docImage
        case "xlsx", "xls", "csv":
            return config.excelImage
        case "pdf":
            return config.pdfImage
        case "jpeg", "jpg", "png", "bmp":
            return config.picImage
        case "mp3", "wav", "wma", "aac", "flac", "m4a", "oga", "opu":
            return config.audioImage
        case "mp4", "3gp", "mgp", "mpeg", "3g2", "avi", "flv", "wmv", "h264",
            "m4v", "mj2", "mov", "ogg", "ogv", "rm", "qt", "vob", "webm":
            return config.videoImage
        case "alf":
            return config.alfImage
        default:
            return config.unknownImage
        }
    }
}
