//
//  AgoraPollModel.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import Foundation
// MARK: - Message
enum AgoraPollInteractionSignal: Convertable {
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
struct AgoraPollExtraModel: Convertable {
    /**投票状态**/
    var pollState: AgoraPollState
    /**投票器id**/
    var pollId: String
    /**投票模式**/
    var mode: AgoraPollMode
    /**投票题目**/
    var pollTitle: String
    /**选项内容**/
    var pollItems: [String]
    /**投票详情**/
    var pollDetails: Dictionary<Int,AgoraPollDetails>
}

struct AgoraPollUserPropModel: Convertable {
    var pollId: String
    var selectIndex: [Int]
}

struct AgoraPollDetails: Convertable, Equatable {
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

struct AgoraPollStartInfo: Convertable {
    var mode: AgoraPollMode
    var pollItems: [String]
}

struct AgoraPollSubmitInfo: Convertable {
    var pollId: String
    var indexs: [Int]
}

// MARK: - enum
enum AgoraPollState: Int, Convertable {
    case end = 0, during
}

enum AgoraPollMode: Int, Convertable {
    case single = 1, multi
}

// MARK: - HTTP
struct AgoraPollSubmitResponse: Convertable {
    var pollId: String
    /**投票模式**/
    var mode: AgoraPollMode
    /**选项内容**/
    var pollItems: [String]
    /**投票详情**/
    var pollDetails: Dictionary<Int, AgoraPollDetails>
}
