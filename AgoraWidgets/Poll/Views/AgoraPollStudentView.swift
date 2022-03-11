//
//  AgoraPollStudentView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/1.
//

import Foundation
import Masonry
import UIKit

struct AgoraPollSelectInfo {
    var isSingle: Bool
    var title: String
    var items: [String]
}

struct AgoraPollResultInfo {
    var title: String
    var details: Dictionary<Int, AgoraPollDetails>
}

enum AgoraPollStudentViewType {
    case select(AgoraPollSelectInfo)
    case result(AgoraPollResultInfo)
}

protocol AgoraPollStudentViewDelegate: NSObjectProtocol {
    /**学生 提交**/
    func didSubmitIndexs(_ indexs: [Int])
}

class AgoraPollStudentView: UIView {
    /**Data**/
    private weak var delegate: AgoraPollStudentViewDelegate?
    private var title: String = ""
    private var items = [String]()
    
    private var presentedResult: Bool = false
    private var pollDetails = Dictionary<Int, AgoraPollDetails>()
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
    
    private var isSingle: Bool = false {
        didSet {
            modeLabel.text = GetWidgetLocalizableString(object: self,
                                                        key: isSingle ? "FCR_Poll_Single" : "FCR_Poll_Multi")
            selectTable.reloadData()
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
                                                key: "FCR_Poll_Title")
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
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        label.text = GetWidgetLocalizableString(object: self,
                                                key: isSingle ? "FCR_Poll_Single" : "FCR_Poll_Multi")
        label.backgroundColor = UIColor(hex: 0xF9F9FC)
        return label
    }()
    
    private lazy var pollTitleLabel: UILabel = {
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
        tab.register(cellWithClass: AgoraPollSelectCell.self)
        tab.separatorStyle = .none
        tab.isScrollEnabled = (items.count > 4)
        return tab
    }()
    
    private lazy var resultView: AgoraPollResultView = {
        return AgoraPollResultView(title: title,
                                   items: items,
                                   pollDetails: pollDetails)
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 15
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitle(GetWidgetLocalizableString(object: self,
                                                   key: "FCR_Poll_Submit"),
                        for: .normal)
        button.addTarget(self,
                         action: #selector(didSubmitClick),
                         for: .touchUpInside)
        return button
    }()
    
    init(delegate: AgoraPollStudentViewDelegate?) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        createViews()
        createConstrains()
    }
    
    func update(isSingle: Bool,
                isEnd: Bool,
                title: String,
                items: [String],
                pollDetails: Dictionary<Int, AgoraPollDetails>) {
        self.items = items
        self.pollDetails = pollDetails
        self.isSingle = isSingle
        
        if !self.presentedResult,
           !isEnd {
            pollTitleLabel.text = title
            
        } else {
            self.presentedResult = isEnd
            presentResult()
            resultView.update(title: title,
                              items: items,
                              pollDetails: pollDetails)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Table
extension AgoraPollStudentView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "pollCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? AgoraPollSelectCell
        if cell == nil {
            cell = AgoraPollSelectCell(style: .default,
                                         reuseIdentifier: reuseId)
        }
        
        guard items.count > indexPath.row else {
            return cell!
        }
        cell?.updateInfo(AgoraPollCellPollingInfo(isSingle: isSingle,
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
private extension AgoraPollStudentView {
    @objc func didSubmitClick() {
        delegate?.didSubmitIndexs(curChosesIndexs)
    }
    
    func presentResult() {
        guard resultView.superview == nil else {
            return
        }
        
        addSubview(resultView)
        
        resultView.mas_makeConstraints { make in
            make?.top.equalTo()(headerView.mas_bottom)?.offset()(0)
            make?.left.equalTo()(5)
            make?.right.equalTo()(-5)
            make?.bottom.equalTo()(0)
        }
    }

    func createViews() {
        backgroundColor = .white
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0,
                                    height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.cornerRadius = 6
        
        addSubview(headerView)
        
        if presentedResult {
            addSubview(resultView)
        } else {
            addSubview(pollTitleLabel)
            addSubview(selectTable)
            addSubview(submitButton)
            submitEnable = false
        }
    }
    
    func createConstrains() {
        // header
        let headerViewHeight:CGFloat = 30
        
        headerView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(headerViewHeight)
        }
        
        if let titleSize = headerTitle.text?.agora_size(font: headerTitle.font,
                                                        height: headerViewHeight) {
            headerTitle.mas_makeConstraints { make in
                make?.left.equalTo()(10)
                make?.width.equalTo()(titleSize.width)
                make?.top.bottom().equalTo()(0)
            }
        }
        
        if let modeSize = modeLabel.text?.agora_size(font: modeLabel.font,
                                                     height: headerViewHeight) {
            modeLabel.mas_makeConstraints { make in
                make?.left.equalTo()(headerTitle.mas_right)?.offset()(6)
                make?.width.equalTo()(modeSize.width + 16)
                make?.height.equalTo()(16)
                make?.centerY.equalTo()(0)
            }
        }
        
        if presentedResult {
            resultView.mas_makeConstraints { make in
                make?.top.equalTo()(headerView.mas_bottom)?.offset()(0)
                make?.left.equalTo()(5)
                make?.right.equalTo()(-5)
                make?.bottom.equalTo()(30)
            }
        } else {
            // poll content
            if let size = pollTitleLabel.text?.agora_size(font: pollTitleLabel.font) {
                pollTitleLabel.mas_makeConstraints { make in
                    make?.left.equalTo()(15)
                    make?.right.equalTo()(-15)
                    make?.top.equalTo()(headerView.mas_bottom)?.offset()(15)
                    make?.height.equalTo()(size.height)
                }
            }
            
            submitButton.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.width.equalTo()(AgoraWidgetsFit.scale(90))
                make?.height.equalTo()(AgoraWidgetsFit.scale(30))
                make?.bottom.equalTo()(AgoraWidgetsFit.scale(-30))
            }
            
            selectTable.mas_makeConstraints { make in
                make?.left.equalTo()(5)
                make?.right.equalTo()(-5)
                make?.top.equalTo()(pollTitleLabel.mas_bottom)?.offset()(15)
                make?.bottom.equalTo()(submitButton.mas_top)?.offset()(-15)
            }
        }
    }
}
