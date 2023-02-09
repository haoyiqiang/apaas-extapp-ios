//
//  AgoraCloudWidgetModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/17.
//

import Foundation
import UIKit

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

    var uiType: FcrCloudFileViewType {
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
        guard let dic = self.toDictionary(),
              let signal = dic.toObject(AgoraCloudInteractionSignal.self) else {
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




