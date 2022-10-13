//
//  AgoraChatViewModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import Foundation
enum AgoraChatMainViewItem: String,
                            CaseIterable,
                            AgoraWidgetDescription {
    case topBar, announcement, input, muteAll, emoji, image
    
    var agDescription: String {
        return rawValue
    }
}

enum AgoraChatBottomBarFunction {
    case input, emoji, picture, mute
}

enum AgoraChatEmojiType {
    case emoji(name: String)
    case png
    case gif
    case delete(image: UIImage?)
}

enum AgoraChatContentType {
    case messages
    case announcement
}

struct AgoraChatEmojiModel {
    var type: AgoraChatEmojiType
    var image: UIImage?
    var name: String
}

enum AgoraChatMessageViewType {
    case text(AgoraChatTextMessageModel)
    case image(AgoraChatImageMessageModel)
    case notice(String)
}

protocol AgoraChatMessageModel {
    var isLocal: Bool { get set }
    var userRole: String { get set }
    var userName: String { get set }
    var avatar: String? { get set }
}

struct AgoraChatTextMessageModel: AgoraChatMessageModel {
    var isLocal: Bool = false
    var userRole: String
    var userName: String
    var avatar: String?
    var text: String
}

struct AgoraChatImageMessageModel: AgoraChatMessageModel {
    var isLocal: Bool = false
    var userRole: String
    var userName: String
    var avatar: String?
    var image: UIImage?
    var imageRemoteUrl: String?
}

extension Int {
    func toRoleName() -> String {
        switch self {
        case 1:  return "fcr_hyphenate_im_teacher".widgets_localized()
        case 3:  return "fcr_hyphenate_im_assistant".widgets_localized()
        default: return ""
        }
    }
}

extension String {
    func toRoleName() -> String {
        if self == "teacher" || self == "1"{
            return "fcr_hyphenate_im_teacher".widgets_localized()
        } else if self == "assistant" || self == "3"  {
            return "fcr_hyphenate_im_assistant".widgets_localized()
        } else {
            return ""
        }
    }
    
    func toEmojiString() -> String? {
        let scanner = Scanner(string: self)
        var result:UInt32 = 0
        scanner.scanHexInt32(&result)
        guard let scalar = UnicodeScalar(result) else {
            return nil
        }
        let emojiStr = Character(scalar)
        return String(emojiStr)
    }
}
