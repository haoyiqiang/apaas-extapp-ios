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
    static let cellId = "AgoraCloudCell"
    let iconImageView = UIImageView(frame: .zero)
    let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraCloudCell: AgoraUIContentContainer {
    func initViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
    }
    
    func initViewFrame() {
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
    
    func updateViewProperties() {
        let config = UIConfig.cloudStorage.cell
        backgroundColor = config.backgroundColor
        
        nameLabel.textColor = config.label.color
        nameLabel.font = config.label.font
    }
}
