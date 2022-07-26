//
//  AgoraChatModels.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2022/7/19.
//

import Foundation

enum AgoraChatInteractionSignal: Convertable {
    case messageReceived
    case error(String)
    
    private enum CodingKeys: CodingKey {
        case messageReceived
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self,
                                                    forKey: .error) {
            self = .error(value)
        } else if let value = try? container.decodeNil(forKey: .messageReceived) {
            self = .messageReceived
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
        case .error(let x):
            try container.encode(x,
                                 forKey: .error)
        case .messageReceived:
            try container.encodeNil(forKey: .messageReceived)
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

enum AgoraChatErrorType {
    case loginFailed, joinFailed, loginedFromRemote, forcedLogOut, fetchError(Int), sendFailed(Int), muteFailed(Int)
}

extension String {
    func toChatWidgetSignal() -> AgoraChatInteractionSignal? {
        guard let dic = self.toDic(),
              let signal = dic.toObj(AgoraChatInteractionSignal.self) else {
                  return nil
              }
        
        return signal
    }
}

enum AgoraWidgetRoomType: Int {
    case oneToOne = 0
    case lecture = 2
    case small = 4
    case sub = 101
}

enum AgoraWidgetRoleType: String {
    case teacher
    case student
    case assistant
    case observer
}
