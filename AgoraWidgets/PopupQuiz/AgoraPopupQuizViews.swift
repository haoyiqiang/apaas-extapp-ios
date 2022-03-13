//
//  AgoraPopupQuizViews.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/5.
//

import AgoraUIBaseViews
import SwifterSwift
import Masonry
import UIKit

// MAKR: - Top View
class AgoraPopupQuizTopView: UIView {
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let lineLayer = CALayer()
    
    private let backColor = UIColor(hexString: "#191919")
    private let grayColor = UIColor(hexString: "#677386")
    
    let defaultHeight: CGFloat = 30
    
    var selectorState: AgoraPopupQuizState = .unselected {
        didSet {
            timeLabel.textColor = (selectorState == .unselected) ? backColor : grayColor 
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        let selector = GetWidgetLocalizableString(object: self,
                                                  key: "FCR_PopupQuiz")
        
        let font = UIFont.systemFont(ofSize: 13)
        
        let titleSize = selector.agora_size(font: font,
                                            height: defaultHeight)
        
        titleLabel.text = selector
        titleLabel.textColor = backColor
        titleLabel.font = font
        addSubview(titleLabel)
        
        timeLabel.textColor = backColor
        timeLabel.font = font
        timeLabel.textAlignment = .left
        addSubview(timeLabel)
        
        update(timeString: "00:00:00")
        
        lineLayer.backgroundColor = UIColor(hexString: "#EEEEF7")?.cgColor
        self.layer.addSublayer(lineLayer)
        
        backgroundColor = UIColor(hexString: "#F9F9FC")
        
        // Constrains
        titleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(10)
            make?.top.bottom()?.equalTo()(0)
            make?.width.equalTo()(titleSize.width + 2)
        }
     
        timeLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(titleLabel.mas_right)?.offset()(5)
            make?.top.right().bottom()?.equalTo()(0)
        }
    }
    
    func update(timeString: String) {
        timeLabel.text = timeString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(x: 0,
                                 y: bounds.height,
                                 width: bounds.width,
                                 height: 1)
    }
}

// MAKR: - Option Collection View
class AgoraPopupQuizOptionCell: UICollectionViewCell {
    private let grayColor = UIColor(hexString: "#EEEEF7")
    private let darkGrayColor = UIColor(hexString: "#BDBDCA")
    private let blueColor = UIColor(hexString: "#357BF6")
    private let lightBlueColor = UIColor(hexString: "#C0D6FF")
    private let whiteColor = UIColor.white
    
    var optionIsSelected: Bool = false {
        didSet {
            optionLabel.backgroundColor = optionIsSelected ? blueColor : whiteColor
            optionLabel.textColor = optionIsSelected ? whiteColor : darkGrayColor
            layer.borderColor = optionIsSelected ? blueColor?.cgColor : grayColor?.cgColor
        }
    }
    
    // after 'optionIsSelected
    var isEnable: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnable
            
            guard optionIsSelected else {
                return
            }
            
            optionLabel.backgroundColor = isEnable ? blueColor : lightBlueColor
            layer.borderColor = isEnable ? blueColor?.cgColor : lightBlueColor?.cgColor
        }
    }
    
    let optionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(optionLabel)

        optionLabel.textColor = darkGrayColor
        optionLabel.textAlignment = .center
        optionLabel.font = UIFont.systemFont(ofSize: 20)
        
        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        optionLabel.frame = bounds
    }
}

class AgoraPopupQuizOptionCollectionView: UICollectionView {
    init() {
        let layout = UICollectionViewFlowLayout()
        
        super.init(frame: .zero,
                   collectionViewLayout: layout)
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        
        backgroundColor = .white
        bounces = false
        
        register(cellWithClass: AgoraPopupQuizOptionCell.self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MAKR: - Result Table View
class AgoraPopupQuizResultCell: UITableViewCell {
    static let cellId = NSStringFromClass(AgoraPopupQuizResultCell.self)
    static let font = UIFont.systemFont(ofSize: 13)
    static let labelHeight: CGFloat = 18
    
    let titleLabel = UILabel()
    let resultLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(resultLabel)
        
        titleLabel.textColor = UIColor(hexString: "#7B88A0")
        resultLabel.textColor = UIColor(hexString: "#191919")
        
        titleLabel.font = AgoraPopupQuizResultCell.font
        resultLabel.font = AgoraPopupQuizResultCell.font
        
        titleLabel.textAlignment = .left
        resultLabel.textAlignment = .left
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPopupQuizResultTableView: UITableView {
    override init(frame: CGRect,
                  style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        rowHeight = 28
        separatorStyle = .none
        isScrollEnabled = false
        register(AgoraPopupQuizResultCell.self,
                 forCellReuseIdentifier: AgoraPopupQuizResultCell.cellId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MAKR: - Button
class AgoraPopupQuizButton: UIButton {
    private let blueColor = UIColor(hexString: "#357BF6")
    private let lightBlueColor = UIColor(hexString: "#C0D6FF")
    
    var selectorState: AgoraPopupQuizState = .unselected {
        didSet {
            switch selectorState {
            case .post:
                let post = GetWidgetLocalizableString(object: self,
                                                      key: "FCR_PopupQuiz_Post")
                setTitle(post,
                         for: .normal)
                setTitleColor(.white,
                              for: .normal)
                isEnabled = true
                backgroundColor = blueColor
                layer.borderColor = blueColor?.cgColor
            case .change:
                let change = GetWidgetLocalizableString(object: self,
                                                        key: "FCR_PopupQuiz_Change")
                setTitle(change,
                         for: .normal)
                setTitleColor(blueColor,
                              for: .normal)
                isEnabled = true
                backgroundColor = .white
                layer.borderColor = blueColor?.cgColor
            case .unselected:
                let post = GetWidgetLocalizableString(object: self,
                                                      key: "FCR_PopupQuiz_Post")
                setTitle(post,
                         for: .disabled)
                setTitleColor(.white,
                              for: .disabled)
                isEnabled = false
                backgroundColor = lightBlueColor
                layer.borderColor = lightBlueColor?.cgColor
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        cornerRadius = 15
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPopupQuizView: UIView {
    let optionCollectionView = AgoraPopupQuizOptionCollectionView()
    let topView = AgoraPopupQuizTopView()
    let button = AgoraPopupQuizButton()
    let resultTableView = AgoraPopupQuizResultTableView()
    
    let optionCollectionViewHorizontalSpace: CGFloat = 16
    let optionCollectionItemSize = CGSize(width: 40,
                                          height: 40)
    
    var selectorState: AgoraPopupQuizState = .unselected {
        didSet {
            button.selectorState = selectorState
            topView.selectorState = selectorState
            
            guard selectorState == .end else {
                return
            }
            
            optionCollectionView.isHidden = true
            button.isHidden = true
            resultTableView.isHidden = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionViewLayout(superViewSize: CGSize) {
        let rowCount: CGFloat = 4
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let totalSpace = superViewSize.width - (optionCollectionViewHorizontalSpace * 2) - (optionCollectionItemSize.width * rowCount)
        let minSpace = totalSpace / (rowCount - 1)
        
        layout.itemSize = optionCollectionItemSize
        
        layout.minimumLineSpacing = minSpace
        
        optionCollectionView.setCollectionViewLayout(layout,
                                                     animated: false)
    }
    
    private func createViews() {
        selectorState = .unselected
        
        addSubview(topView)
        addSubview(optionCollectionView)
        addSubview(button)
        addSubview(resultTableView)
        
        resultTableView.isHidden = true
        
        backgroundColor = .white
        layer.borderColor = UIColor(hexString: "#E3E3EC")?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.masksToBounds = true
    }
    
    private func createConstraint() {
        topView.mas_makeConstraints { (make) in
            make?.top.right()?.left()?.equalTo()(0)
            make?.height.equalTo()(topView.defaultHeight)
        }
        
        button.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(-20)
            make?.width.equalTo()(80)
            make?.height.equalTo()(30)
        }
        
        optionCollectionView.mas_makeConstraints { (make) in
            make?.top.equalTo()(topView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(optionCollectionViewHorizontalSpace)
            make?.right.equalTo()(-optionCollectionViewHorizontalSpace)
            make?.bottom.equalTo()(button.mas_top)?.offset()(-16)
        }
        
        resultTableView.mas_makeConstraints { (make) in
            make?.top.equalTo()(topView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(0)
            make?.right.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
    }
}
