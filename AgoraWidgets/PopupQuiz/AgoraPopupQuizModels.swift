//
//  AgoraPopupQuizModels.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/6.
//

import UIKit

// View Model
struct AgoraPopupQuizOption {
    var title: String
    var isSelected: Bool
}

struct AgoraPopupQuizResult {
    var title: String
    var result: String
    var titleSize: CGSize
    var resultColor: UIColor? = nil
}

enum AgoraPopupQuizState {
    case unselected, selected, changing, finished
}

// Origin Data
struct AgoraPopupQuizRoomPropertiesData: Codable {
    var popupQuizId: String         // 本题id
    var correctItems: [String]      // 本题正确答案
    var items: [String]             // 所有选项
    var correctCount: Int           // 本题答对人数
    var averageAccuracy: Float      // 答题正确率
    var answerState: Int            // 答题状态 1:答题中 0：答题结束
    var receiveQuestionTime: Int64  // 收到题目时间, millisecond
    var selectedCount: Int?         // 已经答题人数
    var totalCount: Int             // 应该答题的人数
    
    func toViewSelectorState() -> AgoraPopupQuizState? {
        if answerState == 0 {
            return .finished
        } else {
            return nil
        }
    }
    
    func toViewSelectorOptionList(myAnswer: [String]?) -> [AgoraPopupQuizOption] {
        var list = [AgoraPopupQuizOption]()
        
        for item in items {
            var isSelected = false
            
            if let list = myAnswer {
                isSelected = list.contains(item)
            }
            
            let option = AgoraPopupQuizOption(title: item,
                                              isSelected: isSelected)
            list.append(option)
        }
        
        return list
    }
    
    func toViewSelectorResultList(font: UIFont,
                                  fontHeight: CGFloat,
                                  myAnswer: [String]?) -> [AgoraPopupQuizResult] {
        var list = [AgoraPopupQuizResult]()
        
        let postfix = ":   "
        
        // Submission
        let submissionTitle = "fcr_popup_quiz_submission".ag_widget_localized() + postfix
        let submissionSize = submissionTitle.agora_size(font: font,
                                                        height: fontHeight)
        var tSelectedCount = selectedCount ?? 0
        let submissionResult = "\(tSelectedCount)/\(totalCount)"
        let submissionItem = AgoraPopupQuizResult(title: submissionTitle,
                                                       result: submissionResult,
                                                       titleSize: submissionSize)
        list.append(submissionItem)
        
        // Accuracy
        let accuracyTitle = "fcr_popup_quiz_accuracy".ag_widget_localized() + postfix
        let accuracySize = accuracyTitle.agora_size(font: font,
                                                    height: fontHeight)
        let accuracyResult = "\(averageAccuracy * 100)%"
        let accuracyItem = AgoraPopupQuizResult(title: accuracyTitle,
                                                     result: accuracyResult,
                                                     titleSize: accuracySize)
        list.append(accuracyItem)
        
        // Correct
        let correctTitle = "fcr_popup_quiz_correct".ag_widget_localized() + postfix
        let correctSize = correctTitle.agora_size(font: font,
                                                  height: fontHeight)
        var correctResult = ""
        
        for item in correctItems {
            correctResult += item
        }
        
        let correctItem = AgoraPopupQuizResult(title: correctTitle,
                                               result: correctResult,
                                               titleSize: correctSize)
        list.append(correctItem)
        
        // My Answer
        let myAnswerTitle = "fcr_popup_quiz_my_answer".ag_widget_localized() + postfix
        let myAnswerSize = myAnswerTitle.agora_size(font: font,
                                                    height: fontHeight)
        
        var myAnswerResult = ""
        
        if let list = myAnswer {
            for item in list {
                myAnswerResult += item
            }
        }
        
        var resultColor: UIColor?
        
        if myAnswerResult == correctResult {
            resultColor = UIColor(hexString: "#0BAD69")
        } else {
            resultColor = UIColor(hexString: "#F04C36")
        }
        
        let myAnswerItem = AgoraPopupQuizResult(title: myAnswerTitle,
                                                result: myAnswerResult,
                                                titleSize: myAnswerSize,
                                                resultColor: resultColor)
        list.append(myAnswerItem)
        
        return list
    }
}

struct AgoraPopupQuizUserPropertiesData: Codable {
    var popupQuizId: String
    var selectedItems: [String]
    var lastCommitTime: Int64
    var isCorrect: Bool  
}
