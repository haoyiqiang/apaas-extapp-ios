//
//  AgoraCloudTopBarView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews
import Masonry
import UIKit

/**
 AgoraCloudTopView
 Data更新：文件数（public/private）
 UI action更新：当前选择（public/private）
 
 通知外部：
 1. 关闭
 2. 关键字查询
 3. 选择文件类型（public/private）
 4. 刷新
 */

protocol AgoraCloudTopViewDelegate: NSObjectProtocol {
    func onTypeButtonPressed(type: FcrCloudFileViewType)
    func onCloseButtonPressed()
    func onRefreshButtonPressed()
    func onSearched(content: String)
}

class AgoraCloudTopView: UIView {
    /// views
    private lazy var contentView1 = UIView()
    private lazy var publicButton = UIButton()
    private lazy var privateButton = UIButton()
    private lazy var closeButton = UIButton()
    private lazy var selectedLine = UIView()
    private lazy var sepLineLayer1 = CALayer()
    
    private lazy var contentView2 = UIView()
    private lazy var refreshButton = UIButton()
    private lazy var pathNameLabel = UILabel()
    private lazy var fileCountLabel = UILabel()
    private lazy var searchBar = UISearchBar()
    private lazy var sepLineLayer2 = CALayer()
    
    private lazy var listHeaderLabel = UILabel()
    private lazy var sepLineLayer3 = CALayer()
    
    // View Size
    let selectedLineSize = CGSize(width: 66,
                                  height: 2)
    
    /// delegate
    weak var delegate: AgoraCloudTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(selectedType: FcrCloudFileViewType) {
        var constraints: ((MASConstraintMaker?) -> Void)
        
        switch selectedType {
        case .uiPublic:
            pathNameLabel.text = "fcr_cloud_public_resource".widgets_localized()
            
            constraints = { make in
                make?.width.equalTo()(self.selectedLineSize.width)
                make?.height.equalTo()(self.selectedLineSize.height)
                make?.bottom.equalTo()(self.contentView1)
                make?.centerX.equalTo()(self.publicButton.mas_centerX)
            }
        case .uiPrivate:
            pathNameLabel.text = "fcr_cloud_private_resource".widgets_localized()
            
            constraints = { make in
                make?.width.equalTo()(self.selectedLineSize.width)
                make?.height.equalTo()(self.selectedLineSize.height)
                make?.bottom.equalTo()(self.contentView1)
                make?.centerX.equalTo()(self.privateButton.mas_centerX)
            }
        }
        
        privateButton.isSelected = !selectedType.isPublic
        publicButton.isSelected = selectedType.isPublic
        
        selectedLine.mas_remakeConstraints(constraints)
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.contentView1.layoutIfNeeded()
        }
    }
    
    func updateFileCount(_ count: Int) {
        let sumText = "fcr_cloud_total_item".widgets_localized()
        let final = sumText.replacingOccurrences(of: String.agora_localized_replacing(),
                                                 with: "\(count)")
        fileCountLabel.text = final
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sepLineLayer1.frame = CGRect(x: 0,
                                     y: 29,
                                     width: bounds.width,
                                     height: 1)
        
        sepLineLayer2.frame = CGRect(x: 0,
                                     y: 59,
                                     width: bounds.width,
                                     height: 1)
        
        sepLineLayer3.frame = CGRect(x: 0,
                                     y: 90,
                                     width: bounds.width,
                                     height: 1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        startSearching()
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraCloudTopView: AgoraUIContentContainer {
    func initViews() {
        let config = UIConfig.cloudStorage
        /// 上半部分
        publicButton.setTitleForAllStates("fcr_cloud_public_resource".widgets_localized())
        privateButton.setTitleForAllStates("fcr_cloud_private_resource".widgets_localized())

        addSubview(contentView1)
        contentView1.addSubview(publicButton)
        contentView1.addSubview(privateButton)
        contentView1.addSubview(closeButton)
        contentView1.addSubview(selectedLine)
        
        /// 下半部分
        pathNameLabel.textAlignment = .left
        
        fileCountLabel.textAlignment = .right
        
        searchBar.placeholder = "fcr_cloud_search".widgets_localized()
        searchBar.delegate = self
        searchBar.textField?.clearButtonMode = .whileEditing
        searchBar.textField?.delegate = self
        
        addSubview(contentView2)
        contentView2.addSubview(refreshButton)
        contentView2.addSubview(pathNameLabel)
        contentView2.addSubview(fileCountLabel)
        contentView2.addSubview(searchBar)
        
        for button in [publicButton,
                       privateButton,
                       closeButton,
                       refreshButton] {
            button.addTarget(self,
                             action: #selector(onButtonPressed(sender:)),
                             for: .touchUpInside)
        }
        
        // list header view
        listHeaderLabel.text = "fcr_cloud_file_name".widgets_localized()
        
        addSubview(listHeaderLabel)
    }
    
    func initViewFrame() {
        /// 上半部分
        contentView1.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(self)
            make?.height.equalTo()(29)
        }
        
        publicButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(19)
        }
        
        privateButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(publicButton.mas_right)?.offset()(40)
        }
        
        selectedLine.mas_makeConstraints { make in
            make?.width.equalTo()(self.selectedLineSize.width)
            make?.height.equalTo()(self.selectedLineSize.height)
            make?.bottom.equalTo()(self.contentView1)
            make?.centerX.equalTo()(publicButton.mas_centerX)
        }
        
        closeButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.width.height().equalTo()(24)
            make?.right.equalTo()(self.contentView1.mas_right)?.offset()(-10)
        }
        /// 下半部分
        contentView2.mas_makeConstraints { make in
            make?.top.equalTo()(contentView1.mas_bottom)?.offset()(1)
            make?.left.right().equalTo()(self)
            make?.height.equalTo()(30)
        }
        
        refreshButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView2)
            make?.left.equalTo()(self.contentView2)?.offset()(15)
            make?.height.equalTo()(26)
            make?.width.equalTo()(26)
        }
        
        pathNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(refreshButton.mas_right)?.offset()(4)
            make?.centerY.equalTo()(self.contentView2)
        }
        
        searchBar.mas_makeConstraints { make in
            make?.width.equalTo()(160)
            make?.height.equalTo()(22)
            make?.right.equalTo()(self)?.offset()(-15)
            make?.centerY.equalTo()(self.contentView2.mas_centerY)
        }
        
        fileCountLabel.mas_makeConstraints { make in
            make?.right.equalTo()(self.searchBar.mas_left)?.offset()(-10)
            make?.centerY.equalTo()(self.contentView2)
        }
        
        listHeaderLabel.mas_makeConstraints { make in
            make?.top.equalTo()(contentView2.mas_bottom)
            make?.left.equalTo()(self)?.offset()(14)
            make?.height.equalTo()(30)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.cloudStorage

        contentView1.backgroundColor = config.backgroundColor
        
        for button in [publicButton,
                       privateButton] {
            button.titleLabel?.font = config.titleLabel.font
            button.setTitleColor(config.titleLabel.normalColor,
                                 for: .normal)
        }
        
        selectedLine.backgroundColor = config.selectedColor

        closeButton.setImage(config.close.image,
                             for: .normal)
        
        refreshButton.setImage(config.refresh.image,
                               for: .normal)
        let search = config.search
        let pix = CGSize(width: 1,
                         height: 1)
        searchBar.backgroundImage = UIImage.init(color: .clear,
                                                 size: pix)
        searchBar.backgroundColor = search.backgroundColor
        searchBar.cornerRadius = 11
        searchBar.layer.borderColor = search.borderColor.cgColor
        searchBar.layer.borderWidth = search.borderWidth
        searchBar.textField?.backgroundColor = search.backgroundColor
        searchBar.textField?.font = search.font
        
        pathNameLabel.textColor = FcrWidgetUIColorGroup.textLevel1Color
        pathNameLabel.font = config.titleLabel.font
        fileCountLabel.textColor = FcrWidgetUIColorGroup.textLevel1Color
        fileCountLabel.font = config.titleLabel.font
        fileCountLabel.backgroundColor = .yellow
        
        contentView2.backgroundColor = config.titleBackgroundColor
        
        listHeaderLabel.textColor = config.titleLabel.normalColor
        listHeaderLabel.font = config.titleLabel.font
        
        for sepLayer in [sepLineLayer1,
                         sepLineLayer2,
                         sepLineLayer3] {
            sepLayer.backgroundColor = config.sepLine.backgroundColor.cgColor
            layer.addSublayer(sepLayer)
        }
    }
}

// MARK: - private
private extension AgoraCloudTopView {
    @objc func onButtonPressed(sender: UIButton) {
        if sender == closeButton {
            delegate?.onCloseButtonPressed()
        } else if sender == publicButton {
            delegate?.onTypeButtonPressed(type: .uiPublic)
        } else if sender == privateButton {
            delegate?.onTypeButtonPressed(type: .uiPrivate)
        } else if sender == refreshButton {
            delegate?.onRefreshButtonPressed()
        }
    }
    
    func startSearching() {
        UIApplication.shared.windows[0].endEditing(true)
        
        guard let text = searchBar.text else {
            delegate?.onSearched(content: "")
            return
        }
        
        delegate?.onSearched(content: text)
    }
}

// MARK: - UISearchBarDelegate
extension AgoraCloudTopView: UISearchBarDelegate, UITextFieldDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startSearching()
    }
    
//    func textField(_ textField: UITextField,
//                   shouldChangeCharactersIn range: NSRange,
//                   replacementString string: String) -> Bool {
//        if string == " " {
//            return false
//        }
//
//
//        guard let str = searchBar.textField?.text else {
//            startSearching()
//            return true
//        }
//
//
//
//        print("ggggggg text: \(searchBar.textField?.text)")
//        print("ggggggg string: \(string)")
//
//        if string == "",
//           (str.count == 1 || str == "") {
//            searchBar.textField?.clear()
//            startSearching()
//        }
//        return true
//    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        startSearching()
        
        return true
    }
}
