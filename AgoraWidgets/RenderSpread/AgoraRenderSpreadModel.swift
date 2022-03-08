//
//  AgoraRenderSpreadModels.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2022/1/7.
//

import Foundation

struct AgoraSpreadExtraModel: Convertable, Equatable {
    var userUuid: String = ""
    
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        if lhs.userUuid == rhs.userUuid {
            return true
        }
        return false
    }
}

struct AgoraSpreadCondition {
    var frameFlag: Bool = false
    var extraFlag: Bool = false
    
    mutating func reset() {
        self.frameFlag = false
        self.extraFlag = false
    }
}

// MARK: To VC
struct AgoraSpreadUserInfo: Convertable {
    var userId: String
    var streamId: String
}

struct AgoraSpreadRenderInfo: Convertable {
    var frame: CGRect
    var user: AgoraSpreadUserInfo
}

enum AgoraSpreadInteractionSignal: Convertable {
    case start(AgoraSpreadRenderInfo)
    case changeFrame(AgoraSpreadRenderInfo)
    case stop
    
    private enum CodingKeys: CodingKey {
        case start
        case changeFrame
        case stop
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .stop) {
            self = .stop
        } else if let value = try? container.decode(AgoraSpreadRenderInfo.self,
                                                    forKey: .start) {
            self = .start(value)
        } else if let value = try? container.decode(AgoraSpreadRenderInfo.self,
                                                    forKey: .changeFrame) {
            self = .changeFrame(value)
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
        case .stop:
            try container.encodeNil(forKey: .stop)
        case .start(let x):
            try container.encode(x,
                                 forKey: .start)
        case .changeFrame(let x):
            try container.encode(x,
                                 forKey: .changeFrame)
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

extension String {
    func vcMessageToSignal() -> AgoraSpreadInteractionSignal? {
        guard let dic = self.toDic(),
              let signal = dic.toObj(AgoraSpreadInteractionSignal.self) else {
                  return nil
              }
        
        return signal
    }
}
