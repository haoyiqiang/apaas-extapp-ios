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
    
    func setOperationPrivilege(_ hasPrivilege: Bool) {
        scaleButton.isHidden = !hasPrivilege
        closeButton.isHidden = !hasPrivilege
        
        let stackWidth = stackWidth(count: hasPrivilege ? 3 : 1)
        buttonsStackView.mas_updateConstraints { make in
            make?.width.equalTo()(stackWidth)
        }
    }
    
    private func initViews() {
        let group = AgoraUIGroup()
        
        layer.borderWidth = group.frame.fcr_border_width
        layer.borderColor = FcrWidgetsColorGroup.fcr_border_color
        layer.cornerRadius = group.frame.fcr_button_corner_radius
        layer.masksToBounds = true
        
        backgroundColor = .clear
        titleLabel.text = "fcr_online_courseware_label_online_courseware".ag_widget_localized()
        titleLabel.font = group.font.fcr_font12
        titleLabel.textColor = FcrWidgetsColorGroup.fcr_text_level1_color
        addSubview(titleLabel)
        
        buttonsStackView.backgroundColor = .clear
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.alignment = .center
        buttonsStackView.spacing = 12
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
    
    private func initViewFrame() {
        let group = AgoraUIGroup()
        let stackWidth = stackWidth(count: 1)
        
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(15)
        }
        
        buttonsStackView.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(-15)
            make?.width.equalTo()(stackWidth)
            make?.height.equalTo()(15)
        }
    }
    
    private func stackWidth(count: Int) -> CGFloat {
        let frame = AgoraUIGroup().frame
        let width: CGFloat = 20 * CGFloat(count) + 12 * CGFloat(count - 1)
        return width
    }
}
