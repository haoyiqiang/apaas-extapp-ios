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
    
    let defaultHeight: CGFloat = 17
    
    var quizState: AgoraPopupQuizState = .unselected {
        didSet {
            timeLabel.textColor = (quizState == .unselected) ? backColor : grayColor
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
                                                  key: "fcr_popup_quiz")
        
        let font = UIFont.systemFont(ofSize: 9)
        
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
        optionLabel.font = UIFont.systemFont(ofSize: 12)
        
        layer.borderWidth = 1
        layer.cornerRadius = 8
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
    static let font = UIFont.systemFont(ofSize: 9)
    
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
        rowHeight = 19
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
    
    var quizState: AgoraPopupQuizState = .unselected {
        didSet {
            switch quizState {
            case .selected:
                let post = GetWidgetLocalizableString(object: self,
                                                      key: "fcr_popup_quiz_post")
                setTitle(post,
                         for: .normal)
                setTitleColor(.white,
                              for: .normal)
                isEnabled = true
                backgroundColor = blueColor
                layer.borderColor = blueColor?.cgColor
            case .changing:
                let change = GetWidgetLocalizableString(object: self,
                                                        key: "fcr_popup_quiz_change")
                setTitle(change,
                         for: .normal)
                setTitleColor(blueColor,
                              for: .normal)
                isEnabled = true
                backgroundColor = .white
                layer.borderColor = blueColor?.cgColor
            case .unselected:
                let post = GetWidgetLocalizableString(object: self,
                                                      key: "fcr_popup_quiz_post")
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
            
            layoutIfNeeded()
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        guard let label = titleLabel,
              let text = label.text else {
                  return
              }
        let textWidth = text.agora_size(font: label.font).width
        
        width = (textWidth > width) ? textWidth : width
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        cornerRadius = 11
        titleLabel?.font = UIFont.systemFont(ofSize: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraPopupQuizView: UIView {
    // View
    let optionCollectionView = AgoraPopupQuizOptionCollectionView()
    let topView = AgoraPopupQuizTopView()
    let button = AgoraPopupQuizButton()
    let resultTableView = AgoraPopupQuizResultTableView()
    
    // Frame
    private(set) var unfinishedNeededSize = CGSize(width: 180,
                                                   height: 106)
    
    let finishedNeededSize = CGSize(width: 180,
                                    height: 142)
    
    private let optionCollectionViewHorizontalSpace: CGFloat = 16
    private let optionCollectionItemSize = CGSize(width: 26,
                                                  height: 26)
    
    var quizState: AgoraPopupQuizState = .unselected {
        didSet {
            button.quizState = quizState
            topView.quizState = quizState
            
            guard quizState == .finished else {
                return
            }
            
            optionCollectionView.isHidden = true
            button.isHidden = true
            resultTableView.isHidden = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionViewLayout() {
        let rowCount: CGFloat = 4
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let totalSpace = unfinishedNeededSize.width - (optionCollectionViewHorizontalSpace * 2) - (optionCollectionItemSize.width * rowCount)
        let minSpace = totalSpace / (rowCount - 1)
        
        layout.itemSize = optionCollectionItemSize
        
        layout.minimumLineSpacing = minSpace
        
        optionCollectionView.setCollectionViewLayout(layout,
                                                     animated: false)
    }
    
    private func initViews() {
        quizState = .unselected
        
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
    
    private func initViewFrame() {
        let topViewWidth = unfinishedNeededSize.width
        let topViewHeight = topView.defaultHeight
        
        topView.frame = CGRect(x: 0,
                               y: 0,
                               width: topViewWidth,
                               height: topViewHeight)
        
        let resultTableViewY: CGFloat = topView.frame.maxY + 20
        let resultTableViewWidth: CGFloat = finishedNeededSize.width
        let resultTableViewHeight: CGFloat = finishedNeededSize.height
        
        resultTableView.frame = CGRect(x: 0,
                                       y: resultTableViewY,
                                       width: resultTableViewWidth,
                                       height: resultTableViewHeight)
        
        collectionViewLayout()
    }
    
    func updateUnfinishedViewFrame(optionCount: Int) {
        let optionCollectionViewX = optionCollectionViewHorizontalSpace
        let optionCollectionViewY = topView.frame.maxY + 15
        let optionCollectionViewWidth = unfinishedNeededSize.width - (optionCollectionViewHorizontalSpace * 2)
        let optionCollectionViewHeight = (optionCount > 4 ? (optionCollectionItemSize.height * 2 + 10) : optionCollectionItemSize.height)
        
        optionCollectionView.frame = CGRect(x: optionCollectionViewX,
                                            y: optionCollectionViewY,
                                            width: optionCollectionViewWidth,
                                            height: optionCollectionViewHeight)
        
        let buttonWidth: CGFloat = 70
        let buttonHeight: CGFloat = 22
        
        let buttonX = (unfinishedNeededSize.width - buttonWidth) * 0.5
        let buttonY = optionCollectionView.frame.maxY + 15
        
        button.frame = CGRect(x: buttonX,
                              y: buttonY,
                              width: buttonWidth,
                              height: buttonHeight)
        button.layoutIfNeeded()
        
        let buttonBottomSpace: CGFloat = 10
        let newHeight: CGFloat = button.frame.maxY + buttonBottomSpace
        let newWidth: CGFloat = unfinishedNeededSize.width
        
        let newSize = CGSize(width: newWidth,
                             height: newHeight)
        
        unfinishedNeededSize = newSize
    }
}
