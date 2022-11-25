//
//  AgoraPollModel.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import Foundation

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
    
    func toViewTitle(font: UIFont,
                     limitWidth: CGFloat) -> AgoraPollViewTitle {
        let size = pollTitle.agora_size(font: font,
                                        width: limitWidth)
        
        return AgoraPollViewTitle(title: pollTitle,
                                  titleSize: size)
    }
    
    func toPollViewSelectedMode() -> AgoraPollViewSelectedMode {
        guard let mode = AgoraPollViewSelectedMode(rawValue: mode) else {
            fatalError()
        }
        
        return mode
    }
    
    func toPollViewOptionList(optionFont: UIFont,
                              optionLabelInsets: UIEdgeInsets,
                              optionWidth: CGFloat,
                              selectedList: [Int]? = nil) -> AgoraPollViewOptionList {
        var array = [AgoraPollViewOption]()
        var height: CGFloat = 0
        
        let limitWidth = optionWidth - optionLabelInsets.left - optionLabelInsets.right
        
        for index in 0..<pollItems.count {
            let item = pollItems[index]
            
            var isSelected: Bool = false
            
            if let list = selectedList {
                isSelected = list.contains(index)
            }
            
            let size = item.agora_size(font: optionFont,
                                       width: limitWidth)
            
            let optionHeight: CGFloat = size.height + optionLabelInsets.top + optionLabelInsets.bottom
            
            let option = AgoraPollViewOption(title: item,
                                             isSelected: isSelected,
                                             height: optionHeight)
            
            height += optionHeight
            
            array.append(option)
        }
        
        let list = AgoraPollViewOptionList(height: height,
                                           items: array)
        
        return list
    }
    
    func toPollViewResultList(resultFont: UIFont,
                              resultTitleLabelInsets: UIEdgeInsets,
                              resultWidth: CGFloat) -> AgoraPollViewResultList {
        var array = [AgoraPollViewResult]()
        var height: CGFloat = 0
        
        let limitWidth = resultWidth - resultTitleLabelInsets.right - resultTitleLabelInsets.left
        
        for index in 0..<pollItems.count {
            guard let detail = pollDetails[index] else {
                continue
            }
            
            let title = pollItems[index]
            let percentage = Int(detail.percentage * 100)
            let resultText = "(\(detail.num)) \(percentage)%"
            
            let size = title.agora_size(font: resultFont,
                                        width: limitWidth)
            
            let resultHeight = size.height + resultTitleLabelInsets.top + resultTitleLabelInsets.bottom
            
            let result = AgoraPollViewResult(title: title,
                                             result: resultText,
                                             percentage: detail.percentage,
                                             height: resultHeight)
            
            height += resultHeight
            
            array.append(result)
        }
        
        let list = AgoraPollViewResultList(height: height,
                                           items: array)
        return list
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

struct AgoraPollViewTitle {
    var title: String
    var titleSize: CGSize
}

// 选项
struct AgoraPollViewOptionList {
    var height: CGFloat
    var items: [AgoraPollViewOption]
}

struct AgoraPollViewOption {
    var title: String
    var isSelected: Bool
    var height: CGFloat
}

// 结果
struct AgoraPollViewResultList {
    var height: CGFloat
    var items: [AgoraPollViewResult]
}

struct AgoraPollViewResult {
    var title: String
    var result: String
    var percentage: Float
    var height: CGFloat
}
