//
//  FcrUIComponents.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrWidgetUIComponentProtocol {
    var visible: Bool {get set}
    var enable: Bool {get set}
    var backgroundColor: UIColor {get set}
}

struct FcrWidgetUIComponentStreamWindow: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.windowCornerRadius
    let borderWidth: CGFloat     = FcrWidgetUIFrameGroup.borderWidth
    let borderColor: CGColor     = FcrWidgetUIColorGroup.borderColor.cgColor
}

struct FcrWidgetUIComponentWebView: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    
    var boardColor: UIColor = FcrWidgetUIColorGroup.borderColor
    var boardWidth: CGFloat = 1
    var cornerRadius: CGFloat = 4
    
    let name = FcrWidgetUIItemWebViewName()
    let refresh = FcrWidgetUIItemWebViewRefresh()
    let scale = FcrWidgetUIItemWebViewScale()
    let close = FcrWidgetUIItemWebViewClose()
    // iOS ui
    let sepLine = FcrWidgetUIItemSepLine()
    let shadow = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentPopupQuiz: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    
    var headerBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemBackgroundColor
    var boardColor: UIColor = FcrWidgetUIColorGroup.borderColor
    var boardWidth: CGFloat = 1
    var cornerRadius: CGFloat = 4
    
    let name = FcrWidgetUIItemPopupQuizName()
    let time = FcrWidgetUIItemPopupQuizTime()
    let option = FcrWidgetUIItemPopupQuizOption()
    let submit = FcrWidgetUIItemPopupQuizSubmit()
    let result = FcrWidgetUIItemPopupQuizResult()
    // iOS ui
    let sepLine = FcrWidgetUIItemSepLine()
    let shadow = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentCounter: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
}

struct FcrWidgetUIComponentCloudStorage: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor      = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    
    let titleBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat         = FcrWidgetUIFrameGroup.containerCornerRadius
    let selectedColor: UIColor        = FcrWidgetUIColorGroup.iconFillColor
    
    let refresh                       = FcrWidgetUIItemCloudStorageRefresh()
    let search                        = FcrWidgetUIItemCloudStorageSearch()
    let close                         = FcrWidgetUIItemCloudStorageClose()
    let cell                          = FcrWidgetUIItemCloudStorageCell()
    let titleLabel                    = FcrWidgetUIItemCloudStorageTitleLabel()
    
    // iOS ui
    let sepLine = FcrWidgetUIItemSepLine()
    let shadow = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentPoll: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    var headerBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemBackgroundColor
    var boardColor: UIColor = FcrWidgetUIColorGroup.borderColor
    var boardWidth: CGFloat = FcrWidgetUIFrameGroup.borderWidth
    var cornerRadius: CGFloat = 4
    
    let name = FcrWidgetUIItemPollName()
    let title = FcrWidgetUIItemPollTitle()
    let option = FcrWidgetUIItemPollOption()
    let result = FcrWidgetUIItemPollResult()
    let submit = FcrWidgetUIItemPollSubmit()
    let shadow = FcrWidgetUIItemShadow()
    let sepLine = FcrWidgetUIItemSepLine()
}

struct FcrWidgetUIComponentNetlessBoard: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    // iOS ui
    let shadow = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentAgoraChat: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    
    let muteAll = FcrWidgetUIItemAgoraChatMuteAll()
    let emoji = FcrWidgetUIItemAgoraChatEmoji()
    let picture = FcrWidgetUIItemAgoraChatPicture()
    
    // iOS ui
    let shadow = FcrWidgetUIItemShadow()
    let topBar = FcrWidgetUIItemAgoraChatTopBar()
}
