//
//  AgoraShareLinkWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Jonathan on 2022/9/28.
//

import AgoraWidget

@objcMembers public class AgoraShareLinkWidget: AgoraNativeWidget {
    
    private let contentView = UIView()
    
    private let closeButton = UIButton(type: .custom)
    
    private let titleLabel = UILabel()
    
    private let roomIdTitleLabel = UILabel()
    
    private let roomIdDetailLabel = UILabel()
    
    private let roomIdCopyButton = UIButton(type: .custom)
    
    private let invitationTitleLabel = UILabel()
    
    private let shareContentView = UIView()
    
    private let shareLinkLabel = UILabel()
    
    private let shareButton = UIButton(type: .custom)
    
    private let copyLinkButton = UIButton(type: .custom)
    
    private var roomId: String? {
        didSet {
            roomIdDetailLabel.text = roomId
        }
    }
    
    private var shareLink: String? {
        didSet {
            shareLinkLabel.text = shareLink
        }
    }
        
    public override func onLoad() {
        super.onLoad()
        
        createViews()
        createConstraints()
        updateInfo()
    }
    
    func updateInfo() {
        if let extra = info.extraInfo as? [String: Any],
           let link = extra["shareLink"] as? String {
            shareLink = link
        }
        roomId = info.roomInfo.roomUuid
    }
}
// MARK: - Actions
private extension AgoraShareLinkWidget {
    @objc func onClickClose(_ sender: UIButton) {
        view.removeFromSuperview()
    }
    
    @objc func onClickCopyId(_ sender: UIButton) {
        guard let rid = roomId else {
            return
        }
        UIPasteboard.general.string = rid
        AgoraToast.toast(message: "fcr_joinroom_tips_copy".widgets_localized(),
                         type: .notice)
    }
    
    @objc func onClickCopyLink(_ sender: UIButton) {
        guard let link = shareLink else {
            return
        }
        UIPasteboard.general.string = link
        AgoraToast.toast(message: "fcr_joinroom_tips_copy".widgets_localized(),
                         type: .notice)
    }
    
    @objc func onClickSendToFriend(_ sender: UIButton) {
        let topVC = UIViewController.agora_top_view_controller()
        let shareURL = URL(string: shareLink)
        let activity = UIActivity()
        let shareVC = UIActivityViewController(activityItems: [shareLink, shareURL],
                                               applicationActivities: [activity])
        topVC.present(shareVC,
                      animated: true)
    }
}
// MARK: - View
private extension AgoraShareLinkWidget {
    func createViews() {
        view.backgroundColor = .black.withAlphaComponent(0.4)
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        closeButton.setImage(.agora_widget_image("fcr_share_close"),
                             for: .normal)
        closeButton.addTarget(self,
                              action: #selector(onClickClose(_:)),
                              for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        titleLabel.text = "fcr_inshare_label_share".widgets_localized()
        titleLabel.textColor = UIColor(hex: 0x191919)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(titleLabel)
        
        roomIdTitleLabel.text = "fcr_inshare_label_room_id".widgets_localized()
        roomIdTitleLabel.textColor = UIColor(hex: 0x586376)
        roomIdTitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(roomIdTitleLabel)
        
        roomIdDetailLabel.text = info.roomInfo.roomUuid
        roomIdDetailLabel.textColor = UIColor(hex: 0x191919)
        roomIdDetailLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(roomIdDetailLabel)
        
        roomIdCopyButton.setImage(.agora_widget_image("fcr_share_id_copy"),
                                  for: .normal)
        roomIdCopyButton.addTarget(self,
                                   action: #selector(onClickCopyId(_:)),
                                   for: .touchUpInside)
        contentView.addSubview(roomIdCopyButton)
        
        invitationTitleLabel.text = "fcr_inshare_label_invitation".widgets_localized()
        invitationTitleLabel.textColor = UIColor(hex: 0x586376)
        invitationTitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(invitationTitleLabel)
        
        shareContentView.backgroundColor = UIColor(hex: 0xF9F9FC)
        shareContentView.layer.cornerRadius = 4
        shareContentView.clipsToBounds = true
        contentView.addSubview(shareContentView)
        
        shareLinkLabel.numberOfLines = 0
        shareLinkLabel.textColor = UIColor(hex: 0xBDBDCA)
        shareLinkLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(shareLinkLabel)
        
        copyLinkButton.setImage(.agora_widget_image("fcr_share_link_copy"),
                                for: .normal)
        copyLinkButton.addTarget(self,
                                 action: #selector(onClickCopyLink(_:)),
                                 for: .touchUpInside)
        contentView.addSubview(copyLinkButton)
        
        shareButton.titleLabel?.textColor = .white
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        shareButton.layer.cornerRadius = 6
        shareButton.clipsToBounds = true
        shareButton.setImage(.agora_widget_image("fcr_share_link_send"),
                             for: .normal)
        shareButton.setTitle("fcr_inshare_button_share_friends".widgets_localized(),
                             for: .normal)
        shareButton.backgroundColor = UIColor(hex: 0x357BF6)
        shareButton.addTarget(self,
                              action: #selector(onClickSendToFriend(_:)),
                              for: .touchUpInside)
        contentView.addSubview(shareButton)
    }
    
    func createConstraints() {
        contentView.mas_makeConstraints { make in
            make?.top.bottom().right().equalTo()(0)
            make?.width.equalTo()(280)
        }
        closeButton.mas_makeConstraints { make in
            make?.top.right().equalTo()(0)
            make?.width.height().equalTo()(44)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(19)
            make?.left.equalTo()(15)
        }
        roomIdTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(24)
            make?.left.equalTo()(titleLabel)
        }
        roomIdDetailLabel.mas_makeConstraints { make in
            make?.left.equalTo()(roomIdTitleLabel.mas_right)?.offset()(10)
            make?.centerY.equalTo()(roomIdTitleLabel)
            make?.width.lessThanOrEqualTo()(160)
        }
        roomIdCopyButton.mas_makeConstraints { make in
            make?.left.equalTo()(roomIdDetailLabel.mas_right)
            make?.width.height().equalTo()(44)
            make?.centerY.equalTo()(roomIdDetailLabel)
        }
        invitationTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(roomIdTitleLabel.mas_bottom)?.offset()(24)
            make?.left.equalTo()(titleLabel)
        }
        shareContentView.mas_makeConstraints { make in
            make?.top.equalTo()(invitationTitleLabel.mas_bottom)?.offset()(16)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.height.equalTo()(118)
        }
        shareLinkLabel.mas_makeConstraints { make in
            make?.top.equalTo()(shareContentView)?.offset()(10)
            make?.left.equalTo()(shareContentView)?.offset()(10)
            make?.right.equalTo()(shareContentView)?.offset()(-10)
        }
        copyLinkButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(24)
            make?.right.equalTo()(shareContentView)?.offset()(-10)
            make?.bottom.equalTo()(shareContentView)?.offset()(-10)
        }
        shareButton.mas_makeConstraints { make in
            make?.left.equalTo()(shareContentView)?.offset()(10)
            make?.bottom.equalTo()(shareContentView)?.offset()(-10)
            make?.height.equalTo()(22)
            make?.right.equalTo()(copyLinkButton.mas_left)?.offset()(-6)
        }
    }
}
