//
//  AgoraCloudContentView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import AgoraUIBaseViews
import Masonry

/**
 AgoraCloudListView
 Data更新：文件列表
 
 通知外部：
 1. 选择cell->文件
 */

class AgoraCloudCell: UITableViewCell {
    
    let iconImageView = UIImageView(frame: .zero)
    let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        backgroundColor = FcrWidgetsColorGroup.fcr_system_component_color
        createViews()
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        nameLabel.textColor = FcrWidgetsColorGroup.fcr_text_level1_color
        nameLabel.font = AgoraUIGroup().font.fcr_font13
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
    }
    
    private func createConstraints() {
        iconImageView.mas_makeConstraints { make in
            make?.height.width().equalTo()(22)
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(self.contentView)
        }
        
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.iconImageView.mas_right)?.offset()(9)
            make?.centerY.equalTo()(self.contentView)
        }
    }
}

class AgoraCloudListView: UITableView {
    let cellId = "AgoraCloudCell"
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        contentInset = .zero
        backgroundColor = FcrWidgetsColorGroup.fcr_system_component_color
        tableFooterView = UIView()
        separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        register(AgoraCloudCell.self,
                 forCellReuseIdentifier: cellId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
