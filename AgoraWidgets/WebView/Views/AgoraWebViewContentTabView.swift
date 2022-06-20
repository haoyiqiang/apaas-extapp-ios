//
//  AgoraWebViewContentTabView.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2022/5/26.
//

import AgoraUIBaseViews

class AgoraWebViewContentTabView: UIView {
    /**Views**/
    private lazy var titleLabel = UILabel()
    private lazy var buttonsStackView = UIStackView(frame: .zero)
    
    private(set) lazy var refreshButton = UIButton()
    private(set) lazy var scaleButton = UIButton()
    private(set) lazy var closeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        let group = AgoraUIGroup()
        
        layer.borderWidth = group.frame.border_width
        layer.borderColor = group.color.web_border_color
        layer.cornerRadius = group.frame.web_corner_radius
        layer.masksToBounds = true
        
        backgroundColor = .clear
        titleLabel.text = "fcr_online_courseware_label_online_courseware".ag_widget_localized()
        titleLabel.font = group.font.web_title_font
        titleLabel.textColor = group.color.web_title_color
        addSubview(titleLabel)
        
        buttonsStackView.backgroundColor = .clear
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .center
        buttonsStackView.spacing = group.frame.web_button_spacing
        addSubview(buttonsStackView)
        
        refreshButton.setImage(UIImage.ag_imageName("web_refresh"),
                               for: .normal)
        scaleButton.setImage(UIImage.ag_imageName("web_scale"),
                               for: .normal)
        closeButton.setImage(UIImage.ag_imageName("web_close"),
                               for: .normal)
        
        buttonsStackView.addArrangedSubview(refreshButton)
        buttonsStackView.addArrangedSubview(scaleButton)
        buttonsStackView.addArrangedSubview(closeButton)
    }
    
    func initViewFrame() {
        let group = AgoraUIGroup()
        let stackWidth = group.frame.web_button_length * 3 + group.frame.web_button_spacing * 2
        
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(group.frame.web_title_side_gap)
        }
        
        buttonsStackView.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(-group.frame.web_title_side_gap)
            make?.width.equalTo()(stackWidth)
            make?.height.equalTo()(group.frame.web_button_length)
        }
    }
}
