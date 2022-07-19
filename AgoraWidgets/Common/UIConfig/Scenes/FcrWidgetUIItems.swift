//
//  FcrUIItems.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrWidgetUIItemProtocol {
    var visible: Bool {get set}
    var enable: Bool {get set}
}

struct FcrWidgetUIItemSepLine: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrWidgetUIColorGroup.systemDividerColor
}

struct FcrWidgetUIItemShadow: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: CGColor  = FcrWidgetUIColorGroup.containerShadowColor.cgColor
    let offset: CGSize  = FcrWidgetUIColorGroup.containerShadowOffset
    let opacity: Float  = FcrWidgetUIColorGroup.shadowOpacity
    let radius: CGFloat = FcrWidgetUIColorGroup.containerShadowRadius
}

// MARK: - PopupQuiz
struct FcrWidgetUIItemPopupQuizName: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
    var text: String                   = "fcr_popup_quiz".agora_widget_localized()
    var textAlignment: NSTextAlignment = .left
    var font: UIFont                   = FcrWidgetUIFontGroup.font9
    var textColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
}

struct FcrWidgetUIItemPopupQuizTime: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
    var textAlignment: NSTextAlignment = .left
    var font: UIFont                   = FcrWidgetUIFontGroup.font9
    var selectedTextColor: UIColor     = FcrWidgetUIColorGroup.textLevel1Color
    var unselectedTextColor: UIColor   = UIColor(hexString: "#677386")!
}

struct FcrWidgetUIItemPopupQuizOption: FcrWidgetUIItemProtocol {
    var visible: Bool                      = true
    var enable: Bool                       = true
    
    var selectedBackgroundColor: UIColor   = FcrWidgetUIColorGroup.iconFillColor
    var selectedBoardColor: UIColor        = FcrWidgetUIColorGroup.iconFillColor
    var selectedTextColor: UIColor         = FcrWidgetUIColorGroup.systemForegroundColor
    
    var unselectedBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    var unselectedBoardColor: UIColor      = FcrWidgetUIColorGroup.borderColor
    var unselectedTextColor: UIColor       = FcrWidgetUIColorGroup.textDisabledColor
    
    var disableBackgroundColor: UIColor    = UIColor(hex: 0xC0D6FF)!
    var disableBoardColor: UIColor         = UIColor(hex: 0xC0D6FF)!
    
    var font: UIFont                       = UIFont.systemFont(ofSize: 12)
    var textAlignment: NSTextAlignment     = .center
    var boardWidth: CGFloat                = 1
    var cornerRadius: CGFloat              = 8
}

struct FcrWidgetUIItemPopupQuizSubmit: FcrWidgetUIItemProtocol {
    var visible: Bool                      = true
    var enable: Bool                       = true
    
    var selectedBackgroundColor: UIColor   = FcrWidgetUIColorGroup.iconFillColor
    var selectedBoardColor: UIColor        = FcrWidgetUIColorGroup.iconFillColor
    var selectedTextColor: UIColor         = FcrWidgetUIColorGroup.systemForegroundColor
    
    var unselectedBackgroundColor: UIColor = UIColor(hexString: "#C0D6FF")!
    var unselectedTextColor: UIColor       = FcrWidgetUIColorGroup.textContrastColor
    var unselectedBoardColor: UIColor      = UIColor(hexString: "#C0D6FF")!
    
    var changingBackgroundColor: UIColor   = FcrWidgetUIColorGroup.systemComponentColor
    var changingBoardColor: UIColor        = FcrWidgetUIColorGroup.iconFillColor
    var changingTextColor: UIColor         = FcrWidgetUIColorGroup.iconFillColor
    
    var boardWidth: CGFloat                = 1
    var cornerRadius: CGFloat              = 11
    var font: UIFont                       = FcrWidgetUIFontGroup.font10
    
    var postText: String                   = "fcr_popup_quiz_post".agora_widget_localized()
    var changeText: String                 = "fcr_popup_quiz_change".agora_widget_localized()
}

struct FcrWidgetUIItemPopupQuizResult: FcrWidgetUIItemProtocol {
    var visible: Bool                      = true
    var enable: Bool                       = true
    var font: UIFont                       = FcrWidgetUIFontGroup.font9
    var textAlignment: NSTextAlignment     = .left
    var rowHeight: CGFloat                 = 19
    
    var titleTextColor: UIColor            = FcrWidgetUIColorGroup.textLevel3Color
    var resultNormalTextColor: UIColor     = FcrWidgetUIColorGroup.textLevel1Color
    var resultCorrectTextColor: UIColor    = UIColor(hexString: "#0BAD69")!
    var resultIncorrectTextColor: UIColor  = UIColor(hexString: "#F04C36")!
    
    var submissionTitle: String            = "fcr_popup_quiz_submission".agora_widget_localized()
    var accuracyTitle: String              = "fcr_popup_quiz_accuracy".agora_widget_localized()
    var correctTitle: String               = "fcr_popup_quiz_correct".agora_widget_localized()
    var myAnswerTitle: String              = "fcr_popup_quiz_my_answer".agora_widget_localized()
}

// MARK: - Poll
struct FcrWidgetUIItemPollName: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
    var text: String                   = "fcr_poll_title".agora_widget_localized()
    var singleMode: String             = "fcr_poll_single".agora_widget_localized()
    var multiMode: String              = "fcr_poll_multi".agora_widget_localized()
    
    var textAlignment: NSTextAlignment = .left
    var font: UIFont                   = FcrWidgetUIFontGroup.font9
    var textColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
}

struct FcrWidgetUIItemPollTitle: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
   
    var textAlignment: NSTextAlignment = .left
    var font: UIFont                   = FcrWidgetUIFontGroup.font9
    var textColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
}

struct FcrWidgetUIItemPollOption: FcrWidgetUIItemProtocol {
    var visible: Bool                       = true
    var enable: Bool                        = true
   
    var textAlignment: NSTextAlignment      = .left
    var font: UIFont                        = FcrWidgetUIFontGroup.font9
    var textColor: UIColor                  = FcrWidgetUIColorGroup.textLevel1Color
    
    var selectedSingleModeImage: UIImage    = UIImage.agora_widget_image("poll_sin_checked")!
    var selectedMultiModeImage: UIImage     = UIImage.agora_widget_image("poll_mul_checked")!
    var unselectedSingleModeImage: UIImage  = UIImage.agora_widget_image("poll_sin_unchecked")!
    var unselectedMultiModeImage: UIImage   = UIImage.agora_widget_image("poll_mul_unchecked")!
    
    var labelVerticalSpace: CGFloat         = 5
    var labelLeftSpace: CGFloat             = 37
    var labelRightSpace: CGFloat            = 15
}

struct FcrWidgetUIItemPollResult: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var titleTextAlignment: NSTextAlignment  = .left
    var resultTextAlignment: NSTextAlignment = .left
     
    var font: UIFont                         = FcrWidgetUIFontGroup.font9
    var textColor: UIColor                   = FcrWidgetUIColorGroup.textLevel1Color
    
    var progressTrackTintColor: UIColor      = UIColor(hex: 0xF9F9FC)!
    var progressTintColor: UIColor           = UIColor(hex: 0x0073FF)!
    
    var labelHorizontalSpace: CGFloat        = 15
    var labelVerticalSpace: CGFloat          = 15
    var labelWidth: CGFloat                  = 50
}

struct FcrWidgetUIItemPollSubmit: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var text: String                         = "fcr_poll_submit".agora_widget_localized()
    var font: UIFont                         = FcrWidgetUIFontGroup.font10
    var textColor: UIColor                   = FcrWidgetUIColorGroup.textContrastColor
    var cornerRadius: CGFloat                = 11
}

// MARK: - WebView
struct FcrWidgetUIItemWebViewName: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var text: String                         = "fcr_online_courseware_label_online_courseware".agora_widget_localized()
    var font: UIFont                         = FcrWidgetUIFontGroup.font12
    var textColor: UIColor                   = FcrWidgetUIColorGroup.textLevel1Color
}

struct FcrWidgetUIItemWebViewRefresh: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    var image: UIImage                       = UIImage.agora_widget_image("web_refresh")!
}

struct FcrWidgetUIItemWebViewScale: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    var image: UIImage                       = UIImage.agora_widget_image("web_scale")!
}

struct FcrWidgetUIItemWebViewClose: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    var image: UIImage                       = UIImage.agora_widget_image("web_close")!
}

// MARK: - cloud
struct FcrWidgetUIItemCloudStorageCell: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let backgroundColor: UIColor             = FcrWidgetUIColorGroup.systemComponentColor
    
    let label = FcrWidgetUIItemCloudStorageCellLabel()
    let image = FcrWidgetUIItemCloudStorageCellImage()
}

struct FcrWidgetUIItemCloudStorageCellLabel: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let color: UIColor                       = FcrWidgetUIColorGroup.textLevel1Color
    let font: UIFont                         = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemCloudStorageCellImage: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let pptImage: UIImage? = .agora_widget_image("format-PPT")
    let docImage: UIImage? = .agora_widget_image("format-word")
    let excelImage: UIImage? = .agora_widget_image("format-excel")
    let pdfImage: UIImage? = .agora_widget_image("format-pdf")
    let picImage: UIImage? = .agora_widget_image("format-pic")
    let audioImage: UIImage? = .agora_widget_image("format-audio")
    let videoImage: UIImage? = .agora_widget_image("format-video")
    let alfImage: UIImage? = .agora_widget_image("format-alf")
    let unknownImage: UIImage? = .agora_widget_image("format-unknown")
}

struct FcrWidgetUIItemCloudStorageRefresh: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let image: UIImage? = .agora_widget_image("icon_refresh")
}

struct FcrWidgetUIItemCloudStorageSearch: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.containerCornerRadius
    let borderColor: UIColor     = FcrWidgetUIColorGroup.borderColor
    let borderWidth: CGFloat     = FcrWidgetUIFrameGroup.borderWidth
    let font: UIFont             = FcrWidgetUIFontGroup.font12
}

struct FcrWidgetUIItemCloudStorageClose: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let image: UIImage? = .agora_widget_image("cloud_close")
}

struct FcrWidgetUIItemCloudStorageTitleLabel: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let normalColor: UIColor                 = FcrWidgetUIColorGroup.textLevel1Color
    let unselectedColor: UIColor             = FcrWidgetUIColorGroup.textLevel2Color
    let font: UIFont                         = FcrWidgetUIFontGroup.font12
}

// MARK: - AgoraChat
struct FcrWidgetUIItemAgoraChatMuteAll: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let selectedColor: UIColor = FcrWidgetUIColorGroup.iconFillColor
    let titleColor: UIColor    = FcrWidgetUIColorGroup.textLevel1Color
    let titleFont: UIFont      = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemAgoraChatEmoji: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let selectedColor: UIColor = FcrWidgetUIColorGroup.iconFillColor
    let titleColor: UIColor    = FcrWidgetUIColorGroup.textLevel1Color
    let titleFont: UIFont      = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemAgoraChatPicture: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let selectedColor: UIColor = FcrWidgetUIColorGroup.iconFillColor
    let titleColor: UIColor    = FcrWidgetUIColorGroup.textLevel1Color
    let titleFont: UIFont      = FcrWidgetUIFontGroup.font13
}
struct FcrWidgetUIItemAgoraChatTopBar: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let selectedColor: UIColor = FcrWidgetUIColorGroup.iconFillColor
    let titleColor: UIColor    = FcrWidgetUIColorGroup.textLevel1Color
    let titleFont: UIFont      = FcrWidgetUIFontGroup.font13
}
