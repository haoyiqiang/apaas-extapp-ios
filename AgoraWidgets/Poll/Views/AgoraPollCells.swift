//
//  AgoraPollCell.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/1.
//

import Foundation

struct AgoraPollCellPollingInfo {
    var isSingle: Bool
    var isSelected: Bool
    var itemText: String
}

struct AgoraPollCellResultInfo {
    var index: Int
    var itemText: String
    var count: Int
    var percent: Float
}

protocol AgoraPollInputCellDelegate: NSObjectProtocol {
    func onItemInput(index: Int,
                     text: String)
}

class AgoraPollInputCell: UITableViewCell {
    private weak var delegate: AgoraPollInputCellDelegate?
    private var index: Int?
    
    private let serialLabel = UILabel()
    private let optionField = UITextField()
    private let sepLine = UIView()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        serialLabel.textColor = UIColor(hex: 0x677386)
        serialLabel.font = .systemFont(ofSize: 14)
        optionField.font = .systemFont(ofSize: 13)
        optionField.placeholder = GetWidgetLocalizableString(object: self,
                                                             key: "fcr_poll_input_placeholder")
        optionField.delegate = self
        sepLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        
        addSubviews([serialLabel, optionField, sepLine])
        
    }
    
    func updateInfo(index: Int,
                    delegate: AgoraPollInputCellDelegate) {
        self.delegate = delegate
        self.index = index
        serialLabel.text = "\(index)."
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        serialLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
        }
        optionField.mas_makeConstraints { make in
            make?.left.equalTo()(serialLabel.mas_right)?.offset()(AgoraWidgetsFit.scale(10))
            make?.centerY.top().bottom().right().equalTo()(0)
        }
        sepLine.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
        }
    }
}

extension AgoraPollInputCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
        let `index` = index else {
            return
        }
        delegate?.onItemInput(index: index,
                              text: text)
    }
}

