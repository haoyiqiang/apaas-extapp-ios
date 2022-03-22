//
//  AgoraPollViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/11.
//

import Masonry
import UIKit

class AgoraPollHeaderView: UIView {
    private let label = UILabel()
    private let lineLayer = CALayer()
    
    var selectedMode: AgoraPollViewSelectedMode = .single {
        didSet {
            updateTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(x: 0,
                                 y: bounds.height,
                                 width: bounds.width,
                                 height: 1)
    }
    
    private func createViews() {
        let group = AgoraFontGroup()
        label.font = group.poll_label_font
        label.textColor = UIColor(hexString: "#191919")
        
        addSubview(label)
        
        label.mas_makeConstraints { (make) in
            make?.left.equalTo()(8)
            make?.top.bottom()?.right().equalTo()(0)
        }
        
        lineLayer.backgroundColor = UIColor(hexString: "#EEEEF7")?.cgColor
        layer.addSublayer(lineLayer)
        
        updateTitle()
    }
    
    private func updateTitle() {
        let isSingle = (selectedMode == .single)
        let mode = (isSingle ? "fcr_poll_single" : "fcr_poll_multi").ag_widget_localized()
        let title = "fcr_poll_title".ag_widget_localized()
        let fullTitle = title + "  " + "(\(mode))"
        label.text = fullTitle
    }
}

class AgoraPollTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let group = AgoraFontGroup()
        font = group.poll_label_font
        textColor = UIColor(hex: 0x191919)
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPollOptionCell: UITableViewCell {
    static let cellId = NSStringFromClass(AgoraPollOptionCell.self)
    
    private let optionImageView = UIImageView()
    private let sepLine = UIView()
    
    let optionLabel = UILabel()
    
    // set 'selectedMode' before 'optionIsSelected'
    var selectedMode: AgoraPollViewSelectedMode = .single
    
    var optionIsSelected: Bool = false {
        didSet {
            setOptionImage()
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        initViews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setOptionImage() {
        var imageName: String
        
        switch selectedMode {
        case .single:
            imageName = optionIsSelected ? "poll_sin_checked" : "poll_sin_unchecked"
        case .multi:
            imageName = optionIsSelected ? "poll_mul_checked" : "poll_mul_unchecked"
        default:
            fatalError()
        }
        
        optionImageView.image = UIImage.ag_imageName(imageName)
    }
    
    private func initViews() {
        selectionStyle = .none
        
        let group = AgoraFontGroup()
        
        optionLabel.font = group.poll_label_font
        optionLabel.numberOfLines = 0
        
        sepLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        
        addSubviews([optionImageView,
                     optionLabel,
                     sepLine])
    }
    
    private func initConstraints() {
        let horizontalSpace: CGFloat = 15
        let group = AgoraFrameGroup()
        
        optionImageView.mas_makeConstraints { make in
            make?.left.equalTo()(horizontalSpace)
            make?.top.equalTo()(5)
            make?.width.height().equalTo()(12)
        }
        
        let labelTop: CGFloat = group.poll_option_label_vertical_space
        let labelBottom: CGFloat = group.poll_option_label_vertical_space
        let labelLeft: CGFloat = group.poll_option_label_left_space
        let labelRight: CGFloat = group.poll_option_label_right_space

        optionLabel.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.left.equalTo()(labelLeft)
            make?.right.equalTo()(-labelRight)
            make?.bottom.equalTo()(-0)
        }
        
        sepLine.mas_makeConstraints { make in
            make?.left.equalTo()(horizontalSpace)
            make?.right.equalTo()(-horizontalSpace)
            make?.height.equalTo()(1)
            make?.bottom.equalTo()(0)
        }
    }
}

class AgoraPollResultCell: UITableViewCell {
    static let cellId = NSStringFromClass(AgoraPollResultCell.self)
    
    /**Views**/
    let titleLabel = UILabel()
    let resultLabel = UILabel()
    let resultProgressView = UIProgressView()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        initViews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        selectionStyle = .none
        let group = AgoraFontGroup()
        let textColor = UIColor(hexString: "#191919")
        let font = group.poll_label_font
        
        titleLabel.textColor = textColor
        titleLabel.font = font
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        resultLabel.textColor = textColor
        resultLabel.font = font
        resultLabel.textAlignment = .right
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.sizeToFit()
        
        resultProgressView.layer.cornerRadius = 1.5
        resultProgressView.trackTintColor = UIColor(hexString: "#F9F9FC")
        resultProgressView.progressTintColor = UIColor(hex: 0x0073FF)
        
        addSubviews([titleLabel,
                     resultLabel,
                     resultProgressView])
    }
    
    private func initConstraints() {
        let group = AgoraFrameGroup()
        
        resultLabel.mas_makeConstraints { (make) in
            make?.top.equalTo()(0)
            make?.right.equalTo()(-group.poll_result_label_horizontal_space)
            make?.width.equalTo()(group.poll_result_value_label_width)
            make?.bottom.equalTo()(0)
        }
        
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.left.equalTo()(group.poll_result_label_horizontal_space)
            make?.right.equalTo()(resultLabel.mas_left)
            make?.bottom.equalTo()(0)
        }
        
        resultProgressView.mas_makeConstraints { make in
            make?.left.equalTo()(group.poll_result_label_horizontal_space)
            make?.right.equalTo()(-group.poll_result_label_horizontal_space)
            make?.bottom.equalTo()(0)
            make?.height.equalTo()(1)
        }
    }
}

class AgoraPollTableView: UITableView {
    var state: AgoraPollViewState = .unselected {
        didSet {
            switch state {
            case .finished:
                register(AgoraPollResultCell.self,
                         forCellReuseIdentifier: AgoraPollResultCell.cellId)
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect,
                  style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        separatorStyle = .none
        isScrollEnabled = false
        rowHeight = 22
        register(AgoraPollOptionCell.self,
                 forCellReuseIdentifier: AgoraPollOptionCell.cellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPollSubmitButton: UIButton {
    var pollState: AgoraPollViewState = .unselected {
        didSet {
            switch pollState {
            case .unselected:
                isEnabled = false
                backgroundColor = UIColor(hexString: "#C0D6FF")
            case .selected:
                isEnabled = true
                backgroundColor = UIColor(hexString: "#357BF6")
            case .finished:
                isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 11
        titleLabel?.font = .systemFont(ofSize: 10)
        
        let title = "fcr_poll_submit".ag_widget_localized()
        
        setTitle(title,
                 for: .normal)
        setTitle(title,
                 for: .disabled)
        
        setTitleColor(.white,
                      for: .normal)
        setTitleColor(.white,
                      for: .disabled)
        
        backgroundColor = UIColor(hexString: "#C0D6FF")
        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
