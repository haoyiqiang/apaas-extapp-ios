//
//  AgoraPollerStudentView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/1.
//

import Foundation
import Masonry
import UIKit

struct AgoraPollerSelectInfo {
    var isSingle: Bool
    var title: String
    var items: [String]
}

struct AgoraPollerResultInfo {
    var title: String
    var details: Dictionary<Int,AgoraPollerDetails>
}

enum AgoraPollerStudentViewType {
    case select(AgoraPollerSelectInfo)
    case result(AgoraPollerResultInfo)
}

protocol AgoraPollerStudentViewDelegate: NSObjectProtocol {
    /**学生 提交**/
    func didSubmitIndexs(_ indexs: [Int])
}

class AgoraPollerStudentView: UIView {
    /**Data**/
    private weak var delegate: AgoraPollerStudentViewDelegate?
    private var title: String = ""
    private var items = [String]()
    private var isSingle: Bool = false
    private var presentedResult: Bool = false
    private var pollingDetails = Dictionary<Int,AgoraPollerDetails>()
    private var curChosesIndexs = [Int]() {
        didSet {
            submitEnable = (curChosesIndexs.count > 0)
        }
    }
    
    private var submitEnable: Bool = false {
        didSet {
            submitButton.isUserInteractionEnabled = submitEnable
            submitButton.backgroundColor = submitEnable ? UIColor(hex: 0x357BF6) : UIColor(hex: 0xC0D6FF)
        }
    }
    /**Views**/
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF9F9FC)

        view.addSubview(headerTitle)
        view.addSubview(modeLabel)
        return view
    }()
    
    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.text = GetWidgetLocalizableString(object: self,
                                                key: "PollerTitle")
        label.textColor = UIColor(hex: 0x191919)
        label.font = .systemFont(ofSize: 13)
        label.sizeToFit()
        return label
    }()
    
    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(hex: 0x357BF6)?.cgColor
        label.textColor = UIColor(hex: 0x357BF6)
        label.layer.cornerRadius = 8
        label.font = .systemFont(ofSize: 11)
        label.sizeToFit()
        label.text = GetWidgetLocalizableString(object: self,
                                                key: isSingle ? "PollerSingle" : "PollerMulti")
        label.backgroundColor = UIColor(hex: 0xEEEEF7)
        return label
    }()
    private lazy var pollingTitle: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = UIColor(hex: 0x191919)
        label.font = .systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    private lazy var selectTable: UITableView = {
        let tab = UITableView()
        tab.delegate = self
        tab.dataSource = self
        tab.register(cellWithClass: AgoraPollerSelectCell.self)
        tab.separatorStyle = .none
        tab.isScrollEnabled = (items.count > 4)
        return tab
    }()
    
    private lazy var resultView: AgoraPollerResultView = {
        return AgoraPollerResultView(title: title,
                                     items: items,
                                     pollingDetails: pollingDetails)
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitle(GetWidgetLocalizableString(object: self,
                                                   key: "PollerSubmit"),
                        for: .normal)
        button.addTarget(self,
                         action: #selector(didSubmitClick),
                         for: .touchUpInside)
        return button
    }()
    
    init(delegate: AgoraPollerStudentViewDelegate?) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        createViews()
        createConstrains()
    }
    
    func update(isSingle: Bool,
                isEnd: Bool,
                title: String,
                items: [String],
                pollingDetails: Dictionary<Int,AgoraPollerDetails>) {
        self.items = items
        self.pollingDetails = pollingDetails
        
        if !self.presentedResult,
           !isEnd {
            selectTable.reloadData()
        } else {
            self.presentedResult = isEnd
            presentResult()
            resultView.update(title: title,
                              items: items,
                              pollingDetails: pollingDetails)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Table
extension AgoraPollerStudentView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "PollingCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? AgoraPollerSelectCell
        if cell == nil {
            cell = AgoraPollerSelectCell(style: .default,
                                         reuseIdentifier: reuseId)
        }
        
        guard items.count > indexPath.row else {
            return cell!
        }
        cell?.updateInfo(AgoraPollerCellPollingInfo(isSingle: isSingle,
                                                    isSelected: curChosesIndexs.contains(indexPath.row),
                                                    itemText: items[indexPath.row]))
        
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
        
        selectTable.reloadData()
    }
}

// MARK: - private
private extension AgoraPollerStudentView {
    @objc func didSubmitClick() {
        delegate?.didSubmitIndexs(curChosesIndexs)
    }
    
    func presentResult() {
        if resultView.superview == nil {
            addSubview(resultView)
            resultView.mas_makeConstraints { make in
                make?.top.equalTo()(headerView.mas_bottom)?.offset()(0)
                make?.left.equalTo()(AgoraWidgetsFit.scale(5))
                make?.right.equalTo()(AgoraWidgetsFit.scale(-5))
                make?.bottom.equalTo()(AgoraWidgetsFit.scale(30))
            }
        }
    }

    func createViews() {
        backgroundColor = .white
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.cornerRadius = 6
        
        addSubview(headerView)
        
        if presentedResult {
            addSubview(resultView)
        } else {
            addSubview(pollingTitle)
            addSubview(selectTable)
            addSubview(submitButton)
            submitEnable = false
        }
    }
    
    func createConstrains() {
        // header
        headerView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(AgoraWidgetsFit.scale(30))
        }
        let titleWidth = headerTitle.text?.agora_size(font: headerTitle.font)
        headerTitle.mas_remakeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
            make?.width.equalTo()(titleWidth)
            make?.top.bottom().equalTo()(0)
        }
        let modeWidth = modeLabel.text?.agora_size(font: modeLabel.font)
        modeLabel.mas_remakeConstraints { make in
            make?.left.equalTo()(headerTitle.mas_right)?.offset()(AgoraWidgetsFit.scale(10))
            make?.width.equalTo()(modeWidth?.width ?? 0 + 12)
            make?.height.equalTo()(modeWidth?.height)
            make?.centerY.equalTo()(0)
        }
        if presentedResult {
            resultView.mas_makeConstraints { make in
                make?.top.equalTo()(headerView.mas_bottom)?.offset()(0)
                make?.left.equalTo()(AgoraWidgetsFit.scale(5))
                make?.right.equalTo()(AgoraWidgetsFit.scale(-5))
                make?.bottom.equalTo()(AgoraWidgetsFit.scale(30))
            }
        } else {
            // polling content
            let size = pollingTitle.text?.agora_size(font: .systemFont(ofSize: 13))
            pollingTitle.mas_remakeConstraints { make in
                make?.left.equalTo()(AgoraWidgetsFit.scale(20))
                make?.right.equalTo()(AgoraWidgetsFit.scale(-20))
                make?.top.equalTo()(headerView.mas_bottom)?.offset()(AgoraWidgetsFit.scale(25))
                make?.height.equalTo()(size?.height)
            }
            
            submitButton.mas_remakeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.width.equalTo()(AgoraWidgetsFit.scale(90))
                make?.height.equalTo()(AgoraWidgetsFit.scale(30))
                make?.bottom.equalTo()(AgoraWidgetsFit.scale(-30))
            }
            
            selectTable.mas_makeConstraints { make in
                make?.left.equalTo()(AgoraWidgetsFit.scale(5))
                make?.right.equalTo()(AgoraWidgetsFit.scale(-5))
                make?.top.equalTo()(pollingTitle.mas_bottom)?.offset()(AgoraWidgetsFit.scale(15))
                make?.bottom.equalTo()(submitButton.mas_top)?.offset()(AgoraWidgetsFit.scale(-15))
            }
        }
    }
}
