//
//  AgoraPollTeacherView.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/3/3.
//

import Foundation
import Masonry
import UIKit

protocol AgoraPollTeacherViewDelegate: NSObjectProtocol {
    /**教师 开启投票**/
    func didStartpoll(isSingle: Bool,
                        pollingItems: [String])
    /**教师 结束投票**/
    func didStoppoll(pollId: String)
}

class AgoraPollTeacherView: UIView {
    /**Data**/
    private weak var delegate: AgoraPollTeacherViewDelegate?
    private var title: String = ""
    private var items = [String]()
    private var isSingle: Bool = true {
        didSet {
            singleBtn.setImage(GetWidgetImage(object: self,
                                              isSingle ? "poll_sin_checked" : "poll_sin_unchecked"), for: .selected)
            
            multiBtn.setImage(GetWidgetImage(object: self,
                                              isSingle ? "poll_sin_unchecked" : "poll_sin_checked"), for: .selected)
        }
    }

    private var curChosesIndexs = [Int]() {
        didSet {
            startEnable = (curChosesIndexs.count > 0)
        }
    }
    
    private var startEnable: Bool = false {
        didSet {
            startButton.isUserInteractionEnabled = startEnable
            startButton.backgroundColor = startEnable ? UIColor(hex: 0x357BF6) : UIColor(hex: 0xC0D6FF)
        }
    }
    
    private let maxInputLength = 100
    
    /**Views**/
    private var headerView = UIView()
    private var exitBtn = UIButton()
    private var headerTitle = UILabel()
    
    private var pollingTitleField = UITextField()
    
    private var singleBtn = UIButton()
    private var multiBtn = UIButton()
    private var pollingTable = UITableView()
    private var addButton = UIButton()
    private var deleteButton = UIButton()
    private var startButton = UIButton()
    
    init(delegate: AgoraPollTeacherViewDelegate?) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        createViews(title: title)
        createConstraint()
    }
    
    func update(isSingle: Bool,
                isEnd: Bool,
                title: String,
                items: [String],
                pollingDetails: Dictionary<Int,AgoraPollDetails>) {
        self.items = items
        
        pollingTable.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Table
extension AgoraPollTeacherView: UITableViewDelegate,UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "AgoraPollInputCell\(indexPath.row)"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? AgoraPollInputCell
        if cell == nil {
            cell = AgoraPollInputCell(style: .default,
                                   reuseIdentifier: reuseId)
        }
        cell?.updateInfo(index: indexPath.row,
                         delegate: self)

        cell?.selectionStyle = .none
        return cell!
        
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row

        if curChosesIndexs.contains(index) {
            curChosesIndexs.removeAll(index)
        } else {
            if isSingle {
                curChosesIndexs.removeAll()
            }
            curChosesIndexs.append(index)
        }
        
        pollingTable.reloadData()
    }
}

extension AgoraPollTeacherView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let strLength = text.count - range.length + string.count
        return strLength <= maxInputLength
    }
}

extension AgoraPollTeacherView: AgoraPollInputCellDelegate {
    func onItemInput(index: Int,
                     text: String) {
        items[index] = text
    }
}

// MARK: - private
private extension AgoraPollTeacherView {
    @objc func onClickStart() {
        delegate?.didStartpoll(isSingle: isSingle,
                                 pollingItems: items)
    }
    
    @objc func onTitleDidChange(_ sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        title = text
    }
    
    @objc func onClickAdd() {
        
    }
    
    @objc func onClickDelete() {
        
    }

    func createViews(title: String) {
        backgroundColor = .white
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.cornerRadius = 6
        
        // header view
        headerView.backgroundColor = UIColor(hex: 0xF9F9FC)
        headerTitle.text = GetWidgetLocalizableString(object: self,
                                                      key: "fcr_poll_title")
        headerTitle.textColor = UIColor(hex: 0x191919)
        headerTitle.font = .systemFont(ofSize: 13)
        headerTitle.sizeToFit()
        
        headerView.addSubview(headerTitle)
        addSubview(headerView)
        
        // pollint content
        pollingTitleField.font = UIFont.systemFont(ofSize: 14)
        pollingTitleField.keyboardType = .emailAddress
        pollingTitleField.delegate = self
        pollingTitleField.addTarget(self,
                                    action: #selector(onTitleDidChange(_:)),
                                    for: .editingChanged)
        
        addSubview(pollingTitleField)
        
        isSingle = true // default
        singleBtn.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                  key: "fcr_poll_single"))
        multiBtn.setTitleForAllStates(GetWidgetLocalizableString(object: self,
                                                                  key: "fcr_poll_multi"))
        singleBtn.titleLabel?.font = .systemFont(ofSize: 12)
        multiBtn.titleLabel?.font = .systemFont(ofSize: 12)
        addSubview(singleBtn)
        addSubview(multiBtn)
        
        pollingTable.delegate = self
        pollingTable.dataSource = self
        pollingTable.register(cellWithClass: AgoraPollResultCell.self)
        pollingTable.separatorStyle = .none
        pollingTable.isScrollEnabled = (items.count > 4)
        addSubview(pollingTable)
        
        // TODO: image缺失
        addButton.setImage(GetWidgetImage(object: self,
                                          "xxxxxxx"),
                           for: .normal)
        addButton.addTarget(self,
                            action: #selector(onClickAdd),
                            for: .touchUpInside)
        deleteButton.addTarget(self,
                               action: #selector(onClickDelete),
                               for: .touchUpInside)
        deleteButton.setImage(GetWidgetImage(object: self,
                                             "xxxxxxx"),
                              for: .normal)
        addSubview(addButton)
        addSubview(deleteButton)
        
        startButton.layer.cornerRadius = 15
        startButton.titleLabel?.font = .systemFont(ofSize: 18)
        startButton.setTitle(GetWidgetLocalizableString(object: self,
                                                        key: "fcr_poll_start"),
                             for: .normal)
        startButton.addTarget(self,
                              action: #selector(onClickStart),
                              for: .touchUpInside)
        startEnable = false
    }
    
    func createConstraint() {
        // header
        headerView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(AgoraWidgetsFit.scale(30))
        }
        headerTitle.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
            make?.centerY.equalTo()(0)
        }
        exitBtn.mas_makeConstraints { make in
            make?.right.equalTo()(AgoraWidgetsFit.scale(-14))
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(AgoraWidgetsFit.scale(24))
        }

        // polling content
        pollingTitleField.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-10))
            make?.top.equalTo()(headerView)?.offset()(AgoraWidgetsFit.scale(14))
            make?.height.equalTo()(AgoraWidgetsFit.scale(65))
        }
        
        multiBtn.mas_makeConstraints { make in
            make?.right.equalTo()(AgoraWidgetsFit.scale(10))
            make?.top.equalTo()(pollingTitleField.mas_bottom)?.offset()(AgoraWidgetsFit.scale(15))
        }
        
        singleBtn.mas_makeConstraints { make in
            make?.right.equalTo()(multiBtn.mas_left)?.offset()(AgoraWidgetsFit.scale(-40))
            make?.top.equalTo()(multiBtn.mas_top)
        }
        
        pollingTable.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(5))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-5))
            make?.top.equalTo()(multiBtn)?.offset()(AgoraWidgetsFit.scale(15))
        }
        
        startButton.mas_remakeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(AgoraWidgetsFit.scale(90))
            make?.height.equalTo()(AgoraWidgetsFit.scale(30))
            make?.bottom.equalTo()(AgoraWidgetsFit.scale(-20))
        }
        
        addButton.mas_makeConstraints { make in
            make?.right.equalTo()(startButton.mas_left)?.equalTo()(AgoraWidgetsFit.scale(-15))
            make?.centerY.equalTo()(startButton.mas_centerY)
            make?.width.height().equalTo()(AgoraWidgetsFit.scale(30))
        }
        
        deleteButton.mas_makeConstraints { make in
            make?.left.equalTo()(startButton.mas_right)?.equalTo()(AgoraWidgetsFit.scale(15))
            make?.centerY.equalTo()(startButton.mas_centerY)
            make?.width.height().equalTo()(AgoraWidgetsFit.scale(30))
        }

        
    }
}
