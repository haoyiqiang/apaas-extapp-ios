//
//  AgoraCloudTopBarView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews
import Masonry

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
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudCoursewareType)
    func agoraCloudTopViewDidTapCloseButton()
    func agoraCloudTopViewDidTapRefreshButton()
    func agoraCloudTopViewDidSearch(type: AgoraCloudUIFileType,
                                    keyStr: String)
}

class AgoraCloudTopView: UIView {
    /// views
    private let contentView1 = UIView()
    private let publicAreaButton = UIButton()
    private let privateAreaButton = UIButton()
    private let closeButton = UIButton()
    private let selectedLine = UIView()
    private let sepLineLayer1 = CALayer()
    
    private let contentView2 = UIView()
    private let refreshButton = UIButton()
    private let pathNameLabel = UILabel()
    private let fileCountLabel = UILabel()
    private let searchBar = UISearchBar()
    private let sepLineLayer2 = CALayer()
    
    /// data
    private var selectedType: AgoraCloudUIFileType = .uiPublic
    private var fileNum = 0
    
    /// delegate
    weak var delegate: AgoraCloudTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTap(sender: UIButton) {
        if sender == closeButton {
            delegate?.agoraCloudTopViewDidTapCloseButton()
        }else if sender == publicAreaButton {
            update(selectedType: .uiPublic)
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .publicResource)
        }else if sender == privateAreaButton {
            update(selectedType: .uiPrivate)
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .privateResource)
        }else if sender == refreshButton {
            delegate?.agoraCloudTopViewDidTapRefreshButton()
        }
    }
    
    func set(fileNum: Int) {
        let sumText = GetWidgetLocalizableString(object: self,
                                                 key: "CloudSum")
        let itemText = GetWidgetLocalizableString(object: self,
                                                  key: "CloudItem")
        fileCountLabel.text = "\(sumText)\(fileNum)\(itemText)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sepLineLayer1.frame = CGRect(x: 0,
                                     y: 30,
                                     width: bounds.width,
                                     height: 1)
        sepLineLayer2.frame = CGRect(x: 0,
                                     y: 60,
                                     width: bounds.width,
                                     height: 1)
    }
}

// MARK: - private
private extension AgoraCloudTopView {
    func initViews() {
        /// 上半部分
        contentView1.backgroundColor = UIColor(hex: 0xF9F9FC)
        let buttonNormalColor = UIColor(hex: 0x586376)
        let buttonSelectedColor = UIColor(hex: 0x191919)
        let lineColor = UIColor(hex: 0xEEEEF7)
        
        publicAreaButton.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                         key: "CloudPublicResource"))
        
        privateAreaButton.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                          key: "CloudPrivateResource"))
        for btn in [publicAreaButton,privateAreaButton] {
            btn.titleLabel?.font = .systemFont(ofSize: 12)
            btn.setTitleColor(buttonNormalColor,
                                            for: .normal)
            btn.setTitleColor(buttonSelectedColor,
                                            for: .selected)
        }
        
        selectedLine.backgroundColor = UIColor(hex: 0x0073FF)

        closeButton.setImage(GetWidgetImage(object: self,
                                            "icon_close"),
                             for: .normal)
        
        sepLineLayer1.backgroundColor = lineColor?.cgColor
        
        addSubview(contentView1)
        contentView1.addSubview(publicAreaButton)
        contentView1.addSubview(privateAreaButton)
        contentView1.addSubview(closeButton)
        contentView1.addSubview(selectedLine)
        
        /// 下半部分
        contentView2.backgroundColor = .white
        let refreshImage = GetWidgetImage(object: self,
                                          "icon_refresh")
        let textColor = UIColor(hex: 0x191919)
        
        refreshButton.setImage(refreshImage,
                               for: .normal)
        
        pathNameLabel.textColor = textColor
        pathNameLabel.font = .systemFont(ofSize: 12)
        pathNameLabel.textAlignment = .left
        
        fileCountLabel.textColor = textColor
        fileCountLabel.font = .systemFont(ofSize: 12)
        fileCountLabel.textAlignment = .right
        
        searchBar.placeholder = GetWidgetLocalizableString(object: self,
                                                           key: "CloudSearch")
        searchBar.delegate = self
        searchBar.backgroundColor = .white
        searchBar.cornerRadius = 4
        searchBar.layer.borderColor = UIColor(hex: 0xD7D7E6)?.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.textField?.font = .systemFont(ofSize: 12)
        searchBar.textField?.backgroundColor = .white
        searchBar.textField?.clearButtonMode = .never
        searchBar.textField?.delegate = self
        
        sepLineLayer2.backgroundColor = lineColor?.cgColor
        
        addSubview(contentView2)
        contentView2.addSubview(refreshButton)
        contentView2.addSubview(pathNameLabel)
        contentView2.addSubview(fileCountLabel)
        contentView2.addSubview(searchBar)
        
        layer.addSublayer(sepLineLayer1)
        layer.addSublayer(sepLineLayer2)
        
        for btn in [publicAreaButton,privateAreaButton,closeButton,refreshButton] {
            btn.addTarget(self,
                          action: #selector(buttonTap(sender:)),
                          for: .touchUpInside)
        }
        
        update(selectedType: selectedType)
    }
    
    func initLayout() {
        /// 上半部分
        contentView1.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(self)
            make?.height.equalTo()(30)
        }
        
        publicAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(24)
            make?.width.equalTo()(80)
        }
        
        privateAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(publicAreaButton.mas_right)
            make?.width.equalTo()(80)
        }
        
        selectedLine.mas_makeConstraints { make in
            make?.width.equalTo()(66)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(self.contentView1)
            make?.centerX.equalTo()(publicAreaButton.mas_centerX)
        }
        
        closeButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.width.height().equalTo()(24)
            make?.right.equalTo()(self.contentView1.mas_right)?.offset()(-10)
        }
        /// 下半部分
        contentView2.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(self)
            make?.height.equalTo()(30)
        }
        
        refreshButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView2)
            make?.left.equalTo()(self.contentView2)?.offset()(21)
            make?.height.equalTo()(26)
            make?.width.equalTo()(26)
        }
        
        pathNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(refreshButton.mas_right)?.offset()(10)
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

    }
    
    func update(selectedType: AgoraCloudUIFileType) {
        self.selectedType = selectedType
        switch selectedType {
        case .uiPublic:
            privateAreaButton.isSelected = false
            publicAreaButton.isSelected = true
            pathNameLabel.text = GetWidgetLocalizableString(object: self,
                                                            key: "CloudPublicResource")
            selectedLine.mas_remakeConstraints { make in
                make?.width.equalTo()(66)
                make?.height.equalTo()(2)
                make?.bottom.equalTo()(self.contentView1)
                make?.centerX.equalTo()(publicAreaButton.mas_centerX)
            }

        case .uiPrivate:
            publicAreaButton.isSelected = false
            privateAreaButton.isSelected = true
            pathNameLabel.text = GetWidgetLocalizableString(object: self,
                                                            key: "CloudPrivateResource")
            selectedLine.mas_remakeConstraints { make in
                make?.width.equalTo()(66)
                make?.height.equalTo()(2)
                make?.bottom.equalTo()(self.contentView1)
                make?.centerX.equalTo()(privateAreaButton.mas_centerX)
            }
            break
        }
    }
    
    func didSearch() {
        UIApplication.shared.windows[0].endEditing(true)
        guard let text = searchBar.text else {
            return
        }
        delegate?.agoraCloudTopViewDidSearch(type: self.selectedType,
                                             keyStr: text)
    }
}

// MARK: - UISearchBarDelegate
extension AgoraCloudTopView: UISearchBarDelegate,UITextFieldDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        didSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didSearch()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        didSearch()
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        didSearch()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let str = searchBar.textField?.text else {
            didSearch()
            return true
        }

        if string == "",
           (str.count == 1 || str == "") {
            searchBar.textField?.clear()
            didSearch()
        }
        return true
    }
}
