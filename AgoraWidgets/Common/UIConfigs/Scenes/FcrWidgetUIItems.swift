//
//  FcrWidgetUIItems.swift
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
    var text: String                   = "fcr_popup_quiz".widgets_localized()
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
    
    var selectedBackgroundColor: UIColor   = FcrWidgetUIColorGroup.systemBrandColor
    var selectedBoardColor: UIColor        = FcrWidgetUIColorGroup.systemBrandColor
    var selectedTextColor: UIColor         = FcrWidgetUIColorGroup.systemForegroundColor
    
    var unselectedBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    var unselectedBoardColor: UIColor      = FcrWidgetUIColorGroup.systemDividerColor
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
    
    var selectedBackgroundColor: UIColor   = FcrWidgetUIColorGroup.systemBrandColor
    var selectedBoardColor: UIColor        = FcrWidgetUIColorGroup.systemBrandColor
    var selectedTextColor: UIColor         = FcrWidgetUIColorGroup.systemForegroundColor
    
    var unselectedBackgroundColor: UIColor = UIColor(hexString: "#C0D6FF")!
    var unselectedTextColor: UIColor       = FcrWidgetUIColorGroup.textContrastColor
    var unselectedBoardColor: UIColor      = UIColor(hexString: "#C0D6FF")!
    
    var changingBackgroundColor: UIColor   = FcrWidgetUIColorGroup.systemComponentColor
    var changingBoardColor: UIColor        = FcrWidgetUIColorGroup.systemBrandColor
    var changingTextColor: UIColor         = FcrWidgetUIColorGroup.systemBrandColor
    
    var boardWidth: CGFloat                = 1
    var cornerRadius: CGFloat              = 11
    var font: UIFont                       = FcrWidgetUIFontGroup.font10
    
    var postText: String                   = "fcr_popup_quiz_post".widgets_localized()
    var changeText: String                 = "fcr_popup_quiz_change".widgets_localized()
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
    
    var submissionTitle: String            = "fcr_popup_quiz_submission".widgets_localized()
    var accuracyTitle: String              = "fcr_popup_quiz_accuracy".widgets_localized()
    var correctTitle: String               = "fcr_popup_quiz_correct".widgets_localized()
    var myAnswerTitle: String              = "fcr_popup_quiz_my_answer".widgets_localized()
}

// MARK: - Counter
struct FcrWidgetUIItemCounterHeader: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
   
    var backgroundColor: UIColor       = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    var font: UIFont                   = FcrWidgetUIFontGroup.font9
    var textColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
    var sepLineColor: UIColor          = FcrWidgetUIColorGroup.systemDividerColor
}

struct FcrWidgetUIItemCounterColon: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
   
    var font: UIFont                   = FcrWidgetUIFontGroup.font10
    var textColor: UIColor             = FcrWidgetUIColorGroup.textLevel2Color
}

struct FcrWidgetUIItemCounterTime: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
   
    var image: UIImage?                = .agora_widget_image("countdown_bg")
    var textAlignment: NSTextAlignment = .center
    var font: UIFont                   = FcrWidgetUIFontGroup.font17.bold
    var normalTextColor: UIColor       = FcrWidgetUIColorGroup.textLevel2Color
    var warnTextColor: UIColor         = FcrWidgetUIColorGroup.systemErrorColor
}
// MARK: - Poll
struct FcrWidgetUIItemPollName: FcrWidgetUIItemProtocol {
    var visible: Bool                  = true
    var enable: Bool                   = true
    var text: String                   = "fcr_poll_title".widgets_localized()
    var singleMode: String             = "fcr_poll_single".widgets_localized()
    var multiMode: String              = "fcr_poll_multi".widgets_localized()
    
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
    
    var text: String                         = "fcr_poll_submit".widgets_localized()
    var font: UIFont                         = FcrWidgetUIFontGroup.font10
    var textColor: UIColor                   = FcrWidgetUIColorGroup.textContrastColor
    var cornerRadius: CGFloat                = 11
}

// MARK: - WebView
struct FcrWidgetUIItemWebViewName: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var text: String                         = "fcr_online_courseware_label_online_courseware".widgets_localized()
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
    
    let pptImage: UIImage?      = .agora_widget_image("format-PPT")
    let docImage: UIImage?      = .agora_widget_image("format-word")
    let excelImage: UIImage?    = .agora_widget_image("format-excel")
    let pdfImage: UIImage?      = .agora_widget_image("format-pdf")
    let picImage: UIImage?      = .agora_widget_image("format-pic")
    let audioImage: UIImage?    = .agora_widget_image("format-audio")
    let videoImage: UIImage?    = .agora_widget_image("format-video")
    let alfImage: UIImage?      = .agora_widget_image("format-alf")
    let unknownImage: UIImage?  = .agora_widget_image("format-unknown")
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
    let borderColor: UIColor     = FcrWidgetUIColorGroup.systemDividerColor
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
    var visible: Bool      = true
    var enable: Bool       = true
    
    var fieldText: String       = "fcr_hyphenate_im_all_mute".widgets_localized()
    var muteText: String        = "fcr_hyphenate_im_teacher_mute_all".widgets_localized()
    var unmuteText: String      = "fcr_hyphenate_im_teacher_unmute_all".widgets_localized()
    var muteImage: UIImage?     = .agora_widget_image("icon_mute")
    var unmuteImage: UIImage?   = .agora_widget_image("icon_unmute")
}

struct FcrWidgetUIItemAgoraChatEmoji: FcrWidgetUIItemProtocol {
    var visible: Bool           = true
    var enable: Bool            = true
    
    var normalImage: UIImage?   = .agora_widget_image("icon_emoji")
    var selectedImage: UIImage? = .agora_widget_image("icon_keyboard")
    var deleteEmoji: UIImage?   = .agora_widget_image("deleteEmoticon")
    
    var textColor = FcrWidgetUIColorGroup.textLevel2Color
    var textFont = FcrWidgetUIFontGroup.font14
}

struct FcrWidgetUIItemAgoraChatPicture: FcrWidgetUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.containerCornerRadius
    var image: UIImage?          = .agora_widget_image("icon_image")
    var noAuthText: String       = "fcr_hyphenate_im_photo_permission_request".widgets_localized()
    var brokenImage: UIImage?    = .agora_widget_image("msg_img_broken")
}

struct FcrWidgetUIItemAgoraChatMute: FcrWidgetUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    var fieldtext: String           = "fcr_hyphenate_im_mute".widgets_localized()
    var muteTextWithName: String    = "fcr_hyphenate_im_muted_by_teacher".widgets_localized()
    var unmuteTextWithName: String  = "fcr_hyphenate_im_unmuted_by_teacher".widgets_localized()
}

struct FcrWidgetUIItemAgoraChatMessage: FcrWidgetUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    var placeholderText: String     = "fcr_hyphenate_im_input_placeholder".widgets_localized()
    var nilText: String             = "fcr_hyphenate_im_no_message".widgets_localized()
    var nilLabelFont: UIFont        = FcrWidgetUIFontGroup.font12
    var nilLabelColor: UIColor      = FcrWidgetUIColorGroup.textLevel2Color
    var nilImage: UIImage?          = .agora_widget_image("icon_message_none")
    
    var sendBar = FcrWidgetUIItemAgoraChatMessageSendBar()
    var cell    = FcrWidgetUIItemAgoraChatMessageCell()
    var notice  = FcrWidgetUIItemAgoraChatNoticeCell()
    var input   = FcrWidgetUIItemAgoraChatInput()
}

struct FcrWidgetUIItemAgoraChatMessageCell: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor        = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    var borderColor: UIColor            = FcrWidgetUIColorGroup.systemDividerColor
    
    var avatarCornerRadius: CGFloat     = FcrWidgetUIFrameGroup.roundContainerCornerRadius
    
    var nameColor: UIColor              = FcrWidgetUIColorGroup.textLevel1Color
    var nameFont: UIFont                = FcrWidgetUIFontGroup.font13
    
    var roleColor: UIColor              = FcrWidgetUIColorGroup.textLevel2Color
    var roleFont: UIFont                = FcrWidgetUIFontGroup.font12
    var roleBorderColor: UIColor        = FcrWidgetUIColorGroup.systemDividerColor
    var roleBorderWidth: CGFloat        = FcrWidgetUIFrameGroup.borderWidth
    var roleCornerRadius: CGFloat       = FcrWidgetUIFrameGroup.containerCornerRadius
    
    var messageCornerRadius: CGFloat    = FcrWidgetUIFrameGroup.containerCornerRadius
    var messageColor: UIColor           = FcrWidgetUIColorGroup.textLevel1Color
    var messageFont: UIFont             = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemAgoraChatMessageSendBar: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var sepLineColor: UIColor = FcrWidgetUIColorGroup.systemDividerColor
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    var inputBackgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    var cornerRadius: CGFloat       = FcrWidgetUIFrameGroup.roundContainerCornerRadius
    var inputButtonTitleColor: UIColor = FcrWidgetUIColorGroup.textLevel2Color
    var inputButtonTitleFont: UIFont = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemAgoraChatNoticeCell: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor    = FcrWidgetUIColorGroup.iconSelectedBackgroundColor
    var image: UIImage?             = .agora_widget_image("icon_caution")
    
    var labelColor: UIColor         = FcrWidgetUIColorGroup.textLevel1Color
    var labelFont: UIFont           = FcrWidgetUIFontGroup.font13
}

struct FcrWidgetUIItemAgoraChatInput: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor            = FcrWidgetUIColorGroup.systemComponentColor
    var fieldBackgroundColor: UIColor       = FcrWidgetUIColorGroup.systemComponentColor
    var fieldTextColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
    
    var sendButtonTitleColor: UIColor       = FcrWidgetUIColorGroup.textContrastColor
    var sendButtonBackgroundColor: UIColor  = FcrWidgetUIColorGroup.systemBrandColor
    var sendButtonTitleFont: UIFont         = FcrWidgetUIFontGroup.font14
    var cornerRadius: CGFloat               = FcrWidgetUIFrameGroup.containerCornerRadius
}

struct FcrWidgetUIItemAgoraChatTopBar: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    let selectedColor: UIColor = FcrWidgetUIColorGroup.systemBrandColor
    let titleColor: UIColor    = FcrWidgetUIColorGroup.textLevel1Color
    let titleFont: UIFont      = FcrWidgetUIFontGroup.font13
    let remindColor: UIColor   = FcrWidgetUIColorGroup.systemErrorColor
}

struct FcrWidgetUIItemAnnouncement: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var labelFont: UIFont               =  FcrWidgetUIFontGroup.font13
    var labelColor: UIColor             = FcrWidgetUIColorGroup.textLevel1Color
    
    var buttonBackgroundColor: UIColor  = FcrWidgetUIColorGroup.systemBackgroundColor
    var buttonTitleFont: UIFont         =  FcrWidgetUIFontGroup.font12
    var buttonTitleColor: UIColor       = FcrWidgetUIColorGroup.textLevel2Color
    var buttonImage: UIImage?           = .agora_widget_image("icon_notice")
    
    var nilImage: UIImage?              = .agora_widget_image("icon_announcement_none")
    var nilText: String                 = "fcr_hyphenate_im_no_announcement".widgets_localized()
    var nilAndSetText: String           = "fcr_hyphenate_im_no_announcement_teacher".widgets_localized()
    
    var nilLabelFont: UIFont            = FcrWidgetUIFontGroup.font12
    var nilLabelNormalColor: UIColor    = FcrWidgetUIColorGroup.textLevel2Color
    var nilLabelLinkColor: UIColor      = FcrWidgetUIColorGroup.textEnabledColor
    
    var edit   = FcrWidgetUIItemAnnouncementEdit()
    var delete = FcrWidgetUIItemAnnouncementDelete()
    var field  = FcrWidgetUIItemAnnouncementField()
    var cancel = FcrWidgetUIItemAnnouncementCancel()
    var issue  = FcrWidgetUIItemAnnouncementIssue()
}


struct FcrWidgetUIItemAnnouncementEdit: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var image: UIImage?  = .agora_widget_image("annoucement_edit")
}


struct FcrWidgetUIItemAnnouncementDelete: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var image: UIImage?  = .agora_widget_image("annoucement_delete")
}

struct FcrWidgetUIItemAnnouncementField: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor        = FcrWidgetUIColorGroup.systemComponentColor
    var borderColor: UIColor            = FcrWidgetUIColorGroup.systemDividerColor
    var borderWidth: CGFloat            = FcrWidgetUIFrameGroup.borderWidth
    var cornerRadius: CGFloat           = FcrWidgetUIFrameGroup.containerCornerRadius
    var textColor: UIColor              = FcrWidgetUIColorGroup.textLevel1Color
    var textFont: UIFont                = FcrWidgetUIFontGroup.font12
    var textCountNormalColor: UIColor   = FcrWidgetUIColorGroup.textLevel1Color
    var textCountWarnColor: UIColor     = FcrWidgetUIColorGroup.systemErrorColor
    var textCountFont: UIFont           = FcrWidgetUIFontGroup.font12
    var warnText: String                = "fcr_hyphenate_im_notice_up_to".widgets_localized()
    var warnTextFont: UIFont            = FcrWidgetUIFontGroup.font10
}

struct FcrWidgetUIItemAnnouncementCancel: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    var title: String            = "fcr_hyphenate_im_notice_cancel".widgets_localized()
    var titleColor: UIColor      = FcrWidgetUIColorGroup.textLevel2Color
    var titleFont: UIFont        = FcrWidgetUIFontGroup.font12
    var borderColor: UIColor     = FcrWidgetUIColorGroup.systemDividerColor
    var borderWidth: CGFloat     = FcrWidgetUIFrameGroup.borderWidth
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.alertCornerRadius
}

struct FcrWidgetUIItemAnnouncementIssue: FcrWidgetUIItemProtocol {
    var visible: Bool                        = true
    var enable: Bool                         = true
    
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemBrandColor
    var title: String            = "fcr_hyphenate_im_notice_send".widgets_localized()
    var titleColor: UIColor      = FcrWidgetUIColorGroup.textContrastColor
    var titleFont: UIFont        = FcrWidgetUIFontGroup.font12
    var borderColor: UIColor     = FcrWidgetUIColorGroup.systemDividerColor
    var borderWidth: CGFloat     = FcrWidgetUIFrameGroup.borderWidth
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.alertCornerRadius
}

// MARK: - NetlessBoard
struct FcrWidgetUIItemNetlessBoardPageControl: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat    = FcrWidgetUIFrameGroup.roundContainerCornerRadius
    
    let addPageImage: UIImage?          = .agora_widget_image("ic_board_page_add")
    let prevPageImage: UIImage?         = .agora_widget_image("ic_board_page_pre")
    let nextPageImage: UIImage?         = .agora_widget_image("ic_board_page_next")
    let disabledPrevPageImage: UIImage? = .agora_widget_image("ic_board_page_disabled_pre")
    let disabledNextPageImage: UIImage? = .agora_widget_image("ic_board_page_disabled_next")
    
    let sepLine        = FcrWidgetUIItemSepLine()
    var pageLabel      = FcrWidgetUIItemNetlessBoardPageLabel()
    let shadow         = FcrWidgetUIItemShadow()
}

struct FcrWidgetUIItemNetlessBoardPageLabel: FcrWidgetUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let color: UIColor  = FcrWidgetUIColorGroup.textLevel2Color
    let font: UIFont    = FcrWidgetUIFontGroup.font14
}

struct FcrWidgetUIItemNetlessBoardMouse: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agora_widget_image("toolcollection_unselecetd_clicker")
    let selectedImage: UIImage?   = .agora_widget_image("toolcollection_selected_clicker")
}

struct FcrWidgetUIItemNetlessBoardSelector: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agora_widget_image("toolcollection_unselecetd_area")
    let selectedImage: UIImage?   = .agora_widget_image("toolcollection_selected_area")
}

struct FcrWidgetUIItemNetlessBoardCourseware: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    var backgroundColor: UIColor = FcrWidgetUIColorGroup.systemComponentColor
}
struct FcrWidgetUIItemNetlessBoardPaint: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agora_widget_image("toolcollection_unselecetd_paint")
    let selectedImage: UIImage?   = .agora_widget_image("toolcollection_selected_paint")
}

struct FcrWidgetUIItemNetlessBoardText: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_text")
}

struct FcrWidgetUIItemNetlessBoardEraser: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agora_widget_image("toolcollection_unselecetd_rubber")
    let selectedImage: UIImage?   = .agora_widget_image("toolcollection_selected_rubber")
}

struct FcrWidgetUIItemNetlessBoardClear: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage? = .agora_widget_image("toolcollection_enabled_clear")
}

struct FcrWidgetUIItemNetlessBoardSave: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?    =  .agora_widget_image("toolcollection_enabled_save")
}

struct FcrWidgetUIItemNetlessBoardPrev: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage?  = .agora_widget_image("toolcollection_enabled_pre")
    let disabledImage: UIImage? = .agora_widget_image("toolcollection_disabled_pre")
}

struct FcrWidgetUIItemNetlessBoardNext: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage?  = .agora_widget_image("toolcollection_enabled_next")
    let disabledImage: UIImage? = .agora_widget_image("toolcollection_disabled_next")
}

// sub for paint
struct FcrWidgetUIItemNetlessBoardPencil: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_pencil")
}

struct FcrWidgetUIItemNetlessBoardLine: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_line")
}

struct FcrWidgetUIItemNetlessBoardRect: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_rect")
}

struct FcrWidgetUIItemNetlessBoardCircle: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_circle")
}

struct FcrWidgetUIItemNetlessBoardPentagram: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_pentagram")
}

struct FcrWidgetUIItemNetlessBoardRhombus: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_rhombus")
}

struct FcrWidgetUIItemNetlessBoardArrow: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?   = .agora_widget_image("toolcollection_arrow")
}

struct FcrWidgetUIItemNetlessBoardTriangle: FcrWidgetUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agora_widget_image("toolcollection_triangle")
}
