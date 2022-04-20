//
//  AgoraStreamWindowModel.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/25.
//

import Foundation

enum AgoraStreamWindowInteractionSignal: Convertable {
    case RenderInfo(AgoraStreamWindowRenderInfo)
    
    private enum CodingKeys: CodingKey {
        case RenderInfo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(AgoraStreamWindowRenderInfo.self,
                                             forKey: .RenderInfo) {
            self = .RenderInfo(value)
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
        case .RenderInfo(let x):
            try container.encode(x,
                                 forKey: .RenderInfo)
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

struct AgoraStreamWindowRenderInfo: Convertable {
    var userUuid: String
    var streamId: String
}

struct AgoraStreamWindowExtraInfo : Convertable {
    // 组件是否为全屏状态
    var contain: Bool
    // 该大窗的用户id
    var userUuid: String
    // 组件纵向层级
    var zIndex: Int
    // 操作者的用户id
    var `operator`: String
}
