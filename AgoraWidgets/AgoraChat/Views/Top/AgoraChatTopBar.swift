//
//  AgoraChatTopView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import AgoraUIBaseViews

protocol AgoraChatTopBarDelegate: NSObjectProtocol {
    func didSelectMessage()
    func didSelectAnnouncement()
}

class AgoraChatTopBar: UIView {
    weak var delegate: AgoraChatTopBarDelegate?
    
    private let buttonLength: CGFloat = 50
    
    private lazy var messageButton = UIButton()
    private lazy var announcementButton = UIButton()
    private lazy var selectedLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func updateAnnouncementVisible(_ visible: Bool) {
        announcementButton.agora_visible = visible
        selectedLine.agora_visible = visible
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgoraChatTopBar: AgoraUIContentContainer {
    func initViews() {
        messageButton.setTitleForAllStates("fcr_hyphenate_im_chat".widgets_localized())
        messageButton.addTarget(self,
                                action: #selector(onClickMessage),
                                for: .touchUpInside)
        announcementButton.setTitleForAllStates("fcr_hyphenate_im_announcement".widgets_localized())
        announcementButton.addTarget(self,
                                action: #selector(onClickAnnouncement),
                                for: .touchUpInside)

        addSubview(messageButton)
        addSubview(announcementButton)
        addSubview(selectedLine)
    }
    
    func initViewFrame() {
        messageButton.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(0)
            make?.width.equalTo()(buttonLength)
        }
        
        announcementButton.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(messageButton.mas_right)
            make?.width.equalTo()(buttonLength)
        }
        
        selectedLine.mas_makeConstraints { make in
            make?.width.equalTo()(buttonLength)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(0)
            make?.left.equalTo()(messageButton.mas_left)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.agoraChat.topBar
        messageButton.setTitleColor(config.titleColor,
                                    for: .normal)
        messageButton.titleLabel?.font = config.titleFont
        announcementButton.setTitleColor(config.titleColor,
                                         for: .normal)
        announcementButton.titleLabel?.font = config.titleFont
        selectedLine.backgroundColor = config.selectedColor
    }
}

private extension AgoraChatTopBar {
    @objc func onClickMessage() {
        selectedLine.mas_remakeConstraints { make in
            make?.width.equalTo()(buttonLength)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(0)
            make?.centerX.equalTo()(messageButton.mas_centerX)
        }
        delegate?.didSelectMessage()
    }
    
    @objc func onClickAnnouncement() {
        selectedLine.mas_remakeConstraints { make in
            make?.width.equalTo()(buttonLength)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(0)
            make?.centerX.equalTo()(announcementButton.mas_centerX)
        }
        delegate?.didSelectAnnouncement()
    }
}
