//
//  AgoraPollerModel.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import Foundation
// MARK: - Message
enum AgoraPollerInteractionSignal: Convertable {
    case frameChange(CGRect)
    
    private enum CodingKeys: CodingKey {
        case frameChange
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let startInfo = try? container.decode(CGRect.self,
                                                 forKey: .frameChange) {
            self = .frameChange(startInfo)
        } else {
            self = .frameChange(.zero)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .frameChange(let value):
            try container.encode(value,
                                 forKey: .frameChange)
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

// MARK: - struct
struct AgoraPollerExtraModel: Convertable {
    /**投票状态**/
    var pollingState: AgoraPollerState
    /**投票器id**/
    var pollingId: String
    /**投票模式**/
    var mode: AgoraPollerMode
    /**投票题目**/
    var pollingTitle: String
    /**选项内容**/
    var pollingItems: [String]
    /**投票详情**/
    var pollingDetails: Dictionary<Int,AgoraPollerDetails>

}

struct AgoraPollerUserPropModel: Convertable {
    var pollingId: String
    var selectIndex: [Int]
}

struct AgoraPollerDetails: Convertable, Equatable {
    /**投票数量**/
    var num: Int = 0
    /**选项占比（选择此选项人数/已经投票人数）**/
    var percentage: Float = 0
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        guard lhs.num == rhs.num,
              lhs.percentage == rhs.percentage else {
                  return false
              }
        return true
    }
}

struct AgoraPollerStartInfo: Convertable {
    var mode: AgoraPollerMode
    var pollingItems: [String]
}

struct AgoraPollerSubmitInfo: Convertable {
    var pollingId: String
    var indexs: [Int]
}

// MARK: - enum
enum AgoraPollerState: Int, Convertable {
    case end = 0,during
}

enum AgoraPollerMode: Int, Convertable {
    case single = 1,multi
}

// MARK: - HTTP
struct AgoraPollerSubmitResponse: Convertable {
    var pollingId: String
    /**投票模式**/
    var mode: AgoraPollerMode
    /**选项内容**/
    var pollingItems: [String]
    /**投票详情**/
    var pollingDetails: Dictionary<Int,AgoraPollerDetails>
}
