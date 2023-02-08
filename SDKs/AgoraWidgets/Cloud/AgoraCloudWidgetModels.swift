//
//  AgoraCloudWidgetModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/17.
//

import Foundation

// MARK: - Message
enum AgoraCloudInteractionSignal: Convertable {
    case openCourseware(AgoraCloudBoardCoursewareInfo)
    case closeCloud
    
    private enum CodingKeys: CodingKey {
        case openCourseware
        case CloseCloud
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .CloseCloud) {
            self = .closeCloud
        } else if let value = try? container.decode(AgoraCloudBoardCoursewareInfo.self,
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

struct AgoraCloudBoardCoursewareInfo: Convertable {
    var resourceUuid: String
    var resourceName: String
    var resourceUrl: String
    var taskUuid: String?
    var prefix: String?
    
    var ext: String
    var scenes: [AgoraCloudBoardCoursewareScene]?
    var convert: Bool?
}

struct AgoraCloudBoardCoursewareScene: Convertable {
    var name: String
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
}

// MARK: - VM
enum AgoraCloudCoursewareType {
    /// 公共资源
    case publicResource
    /// 我的云盘
    case privateResource

    var uiType: AgoraCloudFileViewType {
        switch self {
        case .publicResource:  return .uiPublic
        case .privateResource: return .uiPrivate
        }
    }
}

struct AgoraCloudScene: Convertable {
    var name: String
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
    
    var toCloudBoard: AgoraCloudBoardCoursewareScene {
        return AgoraCloudBoardCoursewareScene(name: name,
                                              src: src,
                                              width: width,
                                              height: height,
                                              preview: preview)
    }
}

// MARK: - Widget
struct AgoraCloudCourseware: Convertable {
    var resourceName: String
    var resourceUuid: String
    var resourceURL: String
    var taskUuid: String?
    var prefix: String?
    
    /// ppt才有
    var scenes: [AgoraCloudScene]?
    /// 原始文件的扩展名
    var ext: String
    // 是否需要转换
    var convert: Bool?
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

extension Array where Element == AgoraCloudScene {
    var toCloudBoard: [AgoraCloudBoardCoursewareScene] {
        return self.map({return $0.toCloudBoard})
    }
}

// MARK: - UI
enum AgoraCloudFileViewType {
    case uiPublic, uiPrivate
    
    var dataType: AgoraCloudCoursewareType {
        switch self {
        case .uiPublic:
            return .publicResource
        case .uiPrivate:
            return .privateResource
        }
    }
    
    var isPublic: Bool {
        switch self {
        case .uiPublic:  return true
        case .uiPrivate: return false
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
        
        self.image = ext.cloudTypeImage()
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

// MARK: - Cloud Server model
extension AgoraCloudServerAPI {
    struct ServerSourceData: Convertable {
        let total: Int
        let list: [FileItem]
        let pageNo: Int
        let pageSize: Int
        let pages: Int
    }
    
    struct FileItem: Convertable {
        // 资源Uuid
        let resourceUuid: String
        // 资源名称
        let resourceName: String
        // 资源父级Uuid (当前文件/文件夹的父级目录的resouceUuid，如果当前目录为根目录则为root)
        let parentResourceUuid: String = "root"
        // 文件/文件夹 (如果是文件则为1，如果是文件夹则为0)
        let type: Int = 1
        // 【需要转换的文件才有】文件转换状态（未转换（0），转换中（1），转换完成（2））
        let convertType: Int?
        // 扩展名
        let ext: String
        // 文件大小
        let size: Double
        // 文件路径
        let url: String
        // 更新时间
        let updateTime: Int64
        // tag列表
        let tags: [String]?
        // 【需要转换的文件才有】
        let taskUuid: String?
        // 【需要转换的文件才有】
        let taskToken: String?
        // 【需要转换的文件才有】
        let taskProgress: TaskProgress?
        // 【需要转换的文件才有】需要转换的文件才有
        let conversion: Conversion?
        // 版本3/4（区分v3/v4）
        var version: Int? = 3
        
        static func create(with data: Data) throws -> FileItem {
            var item = try JSONDecoder().decode(AgoraCloudServerAPI.FileItem.self,
                                                from: data)
            
            if item.version == nil {
                item.version = 3
            }
            
            return item
        }
    }
    
    struct Conversion: Convertable {
        // 动态dynamic，静态static
        let type: String
        let preview: Bool
        // 图片缩放比例
        let scale: Float
        let canvasVersion: Bool?
        // 输出图片格式
        let outputFormat: String
    }
    
    struct TaskProgress: Convertable {
        // task 状态，枚举：Waiting, Converting, Finished, Fail （v3/v4）
        let status: String?
        // 转换文档总页数（v3）
        let totalPageSize: Int?
        // 已经转换完成的页数（v3）
        let convertedPageSize: Int?
        // 转换进度百分比（v3/v4）
        let convertedPercentage: Int
        // 当前转换任务步骤，只有 type == dynamic 时才有该字段（v3）
        let currentStep: String?
        // 转换结果文件地址前缀路径（v3/v4）
        let prefix: String?
        // 文档页数，当文件转换失败时没有该字段（v3/v4）
        let pageCount: Int?
        // 转换文档详情（key：索引,value：url）（v4）
        let previews: [String: String]?
        // 文档提取出的备注内容，只包含有备注的页面（v4）
        let note: String?
        // 错误码，当任务转换失败时会存在（v4）
        let errorCode: String?
        // 错误，当任务转换失败时会存在（v4）
        let errorMessage: String?

        // 转换结果列表（v3）
        let convertedFileList: [TaskProgressConvertedFile]?
        // 转换结果列表（v4）
        let images: [String: TaskProgressImage]?
    }
    
    struct TaskProgressConvertedFile: Convertable {
        public var name: String
        public var ppt: TaskProgressConvertedFilePptPage
    }
    
    struct TaskProgressImage: Convertable {
        // 宽度
        let width: Float
        // 高度
        let height: Float
        // 地址
        let url: String
    }
    
    struct TaskProgressConvertedFilePptPage: Convertable {
        /// 图片的 URL 地址。
        var src: String
        /// 图片的 URL 宽度。单位为像素。
        var width: Float
        /// 图片的 URL 高度。单位为像素。
        var height: Float
        /// 预览图片的 URL 地址
        var preview: String?
    }
}

extension AgoraCloudServerAPI.FileItem {
    var toCloud: AgoraCloudCourseware {
        var scenes: [AgoraCloudScene]?
        
        if version == 4,
           let images = taskProgress?.images {
            var scenesFromNewVersion = [AgoraCloudScene]()
            for (name, image) in images {
                let scene = AgoraCloudScene(name: name,
                                            src: image.url,
                                            width: image.width,
                                            height: image.height,
                                            preview: taskProgress?.previews?[name])
                scenesFromNewVersion.append(scene)
            }
            scenes = scenesFromNewVersion
        } else if version == 3,
                  let list = taskProgress?.convertedFileList {
            var scenesFromOldVersion = [AgoraCloudScene]()
            for file in list {
                let scene = AgoraCloudScene(name: file.name,
                                            src: file.ppt.src,
                                            width: file.ppt.width,
                                            height: file.ppt.height,
                                            preview: file.ppt.preview)
                scenesFromOldVersion.append(scene)
            }
            scenes = scenesFromOldVersion
        }
        
        return AgoraCloudCourseware(resourceName: resourceName,
                                    resourceUuid: resourceUuid,
                                    resourceURL: url,
                                    taskUuid: taskUuid,
                                    prefix: taskProgress?.prefix,
                                    scenes: scenes,
                                    ext: ext,
                                    convert: conversion?.canvasVersion ?? false)
    }
}
