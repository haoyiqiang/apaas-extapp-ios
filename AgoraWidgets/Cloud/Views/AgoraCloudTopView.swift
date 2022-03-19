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
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudUIFileType)
    func agoraCloudTopViewDidTapCloseButton()
    func agoraCloudTopViewDidTapRefreshButton()
    func agoraCloudTopViewDidSearch(keyStr: String)
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
    
    private let listHeaderView = UIView()
    private let sepLineLayer3 = CALayer()
    
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
    
    func update(selectedType: AgoraCloudUIFileType) {
        switch selectedType {
        case .uiPublic:
            privateAreaButton.isSelected = false
            publicAreaButton.isSelected = true
            pathNameLabel.text = GetWidgetLocalizableString(object: self,
                                                            key: "fcr_cloud_public_resource")
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
                                                            key: "fcr_cloud_private_resource")
            selectedLine.mas_remakeConstraints { make in
                make?.width.equalTo()(66)
                make?.height.equalTo()(2)
                make?.bottom.equalTo()(self.contentView1)
                make?.centerX.equalTo()(privateAreaButton.mas_centerX)
            }
            break
        }
    }
    
    func set(fileNum: Int) {
        let sumText = GetWidgetLocalizableString(object: self,
                                                 key: "fcr_cloud_total_item")
        let final = sumText.replacingOccurrences(of: String.ag_localized_replacing(),
                                                 with: "\(fileNum)")
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
        didSearch()
    }
}

// MARK: - private
private extension AgoraCloudTopView {
    @objc func buttonTap(sender: UIButton) {
        if sender == closeButton {
            delegate?.agoraCloudTopViewDidTapCloseButton()
        }else if sender == publicAreaButton {
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .uiPublic)
        }else if sender == privateAreaButton {
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .uiPrivate)
        }else if sender == refreshButton {
            delegate?.agoraCloudTopViewDidTapRefreshButton()
        }
    }
    
    func initViews() {
        let ui = AgoraUIGroup()
        /// 上半部分
        contentView1.backgroundColor = ui.color.cloud_header_1_bg_color
        publicAreaButton.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                         key: "fcr_cloud_public_resource"))
        
        privateAreaButton.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                          key: "fcr_cloud_private_resource"))
        for btn in [publicAreaButton,privateAreaButton] {
            btn.titleLabel?.font = ui.font.cloud_label_font
            btn.setTitleColor(ui.color.cloud_label_color,
                              for: .normal)
        }
        
        selectedLine.backgroundColor = ui.color.cloud_select_line_color

        closeButton.setImage(GetWidgetImage(object: self,
                                            "cloud_close"),
                             for: .normal)

        addSubview(contentView1)
        contentView1.addSubview(publicAreaButton)
        contentView1.addSubview(privateAreaButton)
        contentView1.addSubview(closeButton)
        contentView1.addSubview(selectedLine)
        
        /// 下半部分
        contentView2.backgroundColor = ui.color.cloud_header_2_bg_color
        let refreshImage = GetWidgetImage(object: self,
                                          "icon_refresh")
        refreshButton.setImage(refreshImage,
                               for: .normal)
        
        pathNameLabel.textColor = ui.color.cloud_label_color
        pathNameLabel.font = ui.font.cloud_label_font
        pathNameLabel.textAlignment = .left
        
        fileCountLabel.textColor = ui.color.cloud_label_color
        fileCountLabel.font = ui.font.cloud_label_font
        fileCountLabel.textAlignment = .right
        
        searchBar.placeholder = GetWidgetLocalizableString(object: self,
                                                           key: "fcr_cloud_search")
        searchBar.delegate = self
        searchBar.backgroundColor = ui.color.cloud_header_2_bg_color
        searchBar.cornerRadius = ui.frame.cloud_search_bar_corner_radius
        searchBar.layer.borderColor = ui.color.cloud_search_bar_border_color
        searchBar.layer.borderWidth = ui.frame.cloud_search_bar_border_width
        searchBar.textField?.font = ui.font.cloud_label_font
        searchBar.textField?.backgroundColor = ui.color.cloud_header_2_bg_color
        searchBar.textField?.clearButtonMode = .never
        searchBar.textField?.delegate = self
        
        addSubview(contentView2)
        contentView2.addSubview(refreshButton)
        contentView2.addSubview(pathNameLabel)
        contentView2.addSubview(fileCountLabel)
        contentView2.addSubview(searchBar)
        
        for btn in [publicAreaButton,privateAreaButton,closeButton,refreshButton] {
            btn.addTarget(self,
                          action: #selector(buttonTap(sender:)),
                          for: .touchUpInside)
        }
        // header view
        let nameLabel = UILabel()
        
        listHeaderView.backgroundColor = ui.color.cloud_header_1_bg_color
        nameLabel.text = GetWidgetLocalizableString(object: self,
                                                    key: "fcr_cloud_file_name")
        
        nameLabel.textColor = ui.color.cloud_file_name_label_color
        nameLabel.font = ui.font.cloud_label_font
        
        listHeaderView.addSubview(nameLabel)
        
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.listHeaderView)
            make?.left.equalTo()(self.listHeaderView)?.offset()(14)
        }
        addSubview(listHeaderView)
        
        for sepLayer in [sepLineLayer1, sepLineLayer2, sepLineLayer3] {
            sepLayer.backgroundColor = ui.color.cloud_sep_line_color
            layer.addSublayer(sepLayer)
        }
    }
    
    func initLayout() {
        /// 上半部分
        contentView1.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(self)
            make?.height.equalTo()(29)
        }
        
        publicAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(19)
        }
        
        privateAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(publicAreaButton.mas_right)?.offset()(40)
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
            make?.top.equalTo()(contentView1.mas_bottom)?.offset()(1)
            make?.left.right().equalTo()(self)
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
        
        listHeaderView.mas_makeConstraints { make in
            make?.top.equalTo()(contentView2.mas_bottom)
            make?.left.right().equalTo()(self)
            make?.height.equalTo()(30)
        }

    }
    
    func didSearch() {
        UIApplication.shared.windows[0].endEditing(true)
        guard let text = searchBar.text else {
            delegate?.agoraCloudTopViewDidSearch(keyStr: "")
            return
        }
        delegate?.agoraCloudTopViewDidSearch(keyStr: text)
    }

}

// MARK: - UISearchBarDelegate
extension AgoraCloudTopView: UISearchBarDelegate,UITextFieldDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
