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
    let borderColor: CGColor     = FcrWidgetUIColorGroup.systemDividerColor.cgColor
}

struct FcrWidgetUIComponentWebView: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    
    var boardColor: UIColor = FcrWidgetUIColorGroup.systemDividerColor
    var boardWidth: CGFloat = 1
    var cornerRadius: CGFloat = 4
    var headerBackgroundColor: UIColor = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    
    let name    = FcrWidgetUIItemWebViewName()
    let refresh = FcrWidgetUIItemWebViewRefresh()
    let scale   = FcrWidgetUIItemWebViewScale()
    let close   = FcrWidgetUIItemWebViewClose()
    // iOS ui
    let sepLine = FcrWidgetUIItemSepLine()
    let shadow  = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentPopupQuiz: FcrWidgetUIComponentProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
    var backgroundColor: UIColor       = FcrWidgetUIColorGroup.systemForegroundColor
    
    var headerBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemBackgroundColor
    var boardColor: UIColor            = FcrWidgetUIColorGroup.systemDividerColor
    var boardWidth: CGFloat            = 1
    var cornerRadius: CGFloat          = 4
    
    let name    = FcrWidgetUIItemPopupQuizName()
    let time    = FcrWidgetUIItemPopupQuizTime()
    let option  = FcrWidgetUIItemPopupQuizOption()
    let submit  = FcrWidgetUIItemPopupQuizSubmit()
    let result  = FcrWidgetUIItemPopupQuizResult()
    // iOS ui
    let sepLine = FcrWidgetUIItemSepLine()
    let shadow  = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentCounter: FcrWidgetUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    
    let header                  = FcrWidgetUIItemCounterHeader()
    let colon                   = FcrWidgetUIItemCounterColon()
    let time                    = FcrWidgetUIItemCounterTime()
    
    let sepColor: UIColor       = FcrWidgetUIColorGroup.systemDividerColor.withAlphaComponent(0.3)
    let cornerRadius: CGFloat   = FcrWidgetUIFrameGroup.containerCornerRadius
    var borderColor: UIColor    = FcrWidgetUIColorGroup.systemDividerColor
    var borderWidth: CGFloat    = FcrWidgetUIFrameGroup.borderWidth
    let shadow                  = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentCloudStorage: FcrWidgetUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor      = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    
    let titleBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat         = FcrWidgetUIFrameGroup.containerCornerRadius
    let selectedColor: UIColor        = FcrWidgetUIColorGroup.systemBrandColor
    
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
    var visible: Bool                   = true
    var enable: Bool                    = true
    var backgroundColor: UIColor        = FcrWidgetUIColorGroup.systemForegroundColor
    
    var headerBackgroundColor: UIColor  = FcrWidgetUIColorGroup.systemBackgroundColor
    var borderColor: UIColor            = FcrWidgetUIColorGroup.systemDividerColor
    var borderWidth: CGFloat            = FcrWidgetUIFrameGroup.borderWidth
    var cornerRadius: CGFloat           = 4
    
    let name    = FcrWidgetUIItemPollName()
    let title   = FcrWidgetUIItemPollTitle()
    let option  = FcrWidgetUIItemPollOption()
    let result  = FcrWidgetUIItemPollResult()
    let submit  = FcrWidgetUIItemPollSubmit()
    let shadow  = FcrWidgetUIItemShadow()
    let sepLine = FcrWidgetUIItemSepLine()
}

struct FcrWidgetUIComponentNetlessBoard: FcrWidgetUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemForegroundColor
    /**Scene Builder Set**/
    var mouse       = FcrWidgetUIItemNetlessBoardMouse()
    var selector    = FcrWidgetUIItemNetlessBoardSelector()
    var pencil      = FcrWidgetUIItemNetlessBoardPencil()
    var text        = FcrWidgetUIItemNetlessBoardText()
    var eraser      = FcrWidgetUIItemNetlessBoardEraser()
    var clear       = FcrWidgetUIItemNetlessBoardClear()
    var save        = FcrWidgetUIItemNetlessBoardSave()
    /**iOS**/
    var courseware  = FcrWidgetUIItemNetlessBoardCourseware()
    var paint       = FcrWidgetUIItemNetlessBoardPaint()
    var prev        = FcrWidgetUIItemNetlessBoardPrev()
    var next        = FcrWidgetUIItemNetlessBoardNext()
    var line        = FcrWidgetUIItemNetlessBoardLine()
    var rect        = FcrWidgetUIItemNetlessBoardRect()
    var circle      = FcrWidgetUIItemNetlessBoardCircle()
    var pentagram   = FcrWidgetUIItemNetlessBoardPentagram()
    var rhombus     = FcrWidgetUIItemNetlessBoardRhombus()
    var arrow       = FcrWidgetUIItemNetlessBoardArrow()
    var triangle    = FcrWidgetUIItemNetlessBoardTriangle()
    var pageControl = FcrWidgetUIItemNetlessBoardPageControl()
    // iOS ui
    let shadow = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIComponentAgoraChat: FcrWidgetUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    /**scene builder set**/
    var muteAll      = FcrWidgetUIItemAgoraChatMuteAll()
    var emoji        = FcrWidgetUIItemAgoraChatEmoji()
    var picture      = FcrWidgetUIItemAgoraChatPicture()
    /**ios**/
    var announcement = FcrWidgetUIItemAnnouncement()
    var mute         = FcrWidgetUIItemAgoraChatMute()
    var message      = FcrWidgetUIItemAgoraChatMessage()
    /**ui**/
    let shadow       = FcrWidgetUIItemShadow()
    let topBar       = FcrWidgetUIItemAgoraChatTopBar()
}
