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

// MARK: - Origin Data
// Room Properties
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

struct AgoraPollRoomPropertiesData: Convertable {
    /**投票状态**/
    var pollState: Int
    /**投票器id**/
    var pollId: String
    /**投票模式**/
    var mode: Int
    /**投票题目**/
    var pollTitle: String
    /**选项内容**/
    var pollItems: [String]
    /**投票详情**/
    var pollDetails: Dictionary<Int, AgoraPollDetails>
    
    func toPollViewState() -> AgoraPollViewState? {
        if pollState == 0 {
            return .finished
        } else {
            return nil
        }
    }
        
    func toPollViewOptionList(selectedList: [Int]? = nil ) -> [AgoraPollViewOption] {
        var array = [AgoraPollViewOption]()
        
        for index in 0..<pollItems.count {
            let item = pollItems[index]
            
            var isSelected: Bool = false
            
            if let list = selectedList {
                isSelected = list.contains(index)
            }
            
            let option = AgoraPollViewOption(title: item,
                                             isSelected: isSelected)
            
            array.append(option)
        }
        
        return array
    }
    
    func toPollViewSelectedMode() -> AgoraPollViewSelectedMode {
        guard let mode = AgoraPollViewSelectedMode(rawValue: mode) else {
            fatalError()
        }
        
        return mode
    }
    
    func toPollViewResultList() -> [AgoraPollViewResult] {
        var array = [AgoraPollViewResult]()
        
        for index in 0..<pollItems.count {
            guard let detail = pollDetails[index] else {
                continue
            }
            
            let title = pollItems[index]
            let percentage = Int(detail.percentage * 100)
            let resultText = "(\(detail.num)) \(percentage)%"
            
            let result = AgoraPollViewResult(title: title,
                                             result: resultText,
                                             percentage: detail.percentage)
            array.append(result)
        }
        
        return array
    }
}

// User Properties
struct AgoraPollUserPropertiesData: Convertable {
    var pollId: String
    var selectIndex: [Int]
}

// MARK: - View Model
enum AgoraPollViewState {
    case unselected, selected, finished
}

enum AgoraPollViewSelectedMode: Int, Convertable {
    case single = 1, multi
}

// 选项
struct AgoraPollViewOption {
    var title: String
    var isSelected: Bool
}

// 结果
struct AgoraPollViewResult {
    var title: String
    var result: String
    var percentage: Float
}
