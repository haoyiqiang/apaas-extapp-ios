//
//  AgoraRtmIMSendCell.swift
//  AgoraWidgets
//
//  Created by Jonathan on 2021/12/17.
//

import UIKit

fileprivate let kRoleLabelHeight: CGFloat = 16
fileprivate let kAvatarHeight: CGFloat = 22
class AgoraRtmIMSendCell: UITableViewCell {
    
    var messageModel: AgoraRtmMessageModel? {
        didSet {
            if messageModel != oldValue {
                updateView()
            }
        }
    }

    private var avatarView: UIImageView!
    
    private var bubleView: UIView!
    
    private var nameLabel: UILabel!
    
    private var roleLabel: UILabel!
    
    private var messageLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createViews()
        createConstraint()
    }
    
    public func setMessage(msg: String) {
        messageLabel.text = msg
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateView() {
        guard let model = messageModel  else {
            return
        }
        nameLabel.text = model.name
        messageLabel.text = model.text
        if let str = model.roleName,
           str.count > 0 {
            roleLabel.isHidden = false
            roleLabel.text = "  \(str)  "
        } else {
            roleLabel.isHidden = true
        }
    }
}
// MARK: - Creations
private extension AgoraRtmIMSendCell {
    func createViews() {
        avatarView = UIImageView()
        avatarView.image = UIImage.ag_imageNamed("ic_rtm_avatar",
                                                 in: "AgoraWidgets")
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = kAvatarHeight * 0.5
        contentView.addSubview(avatarView)
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x191919)
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(nameLabel)
        
        roleLabel = UILabel()
        roleLabel.textColor = UIColor(hex: 0x586376)
        roleLabel.font = UIFont.systemFont(ofSize: 12)
        roleLabel.layer.borderWidth = 1
        roleLabel.layer.cornerRadius = kRoleLabelHeight * 0.5
        roleLabel.layer.borderColor = UIColor(hex: 0xABB1BA, transparency: 0.3)?.cgColor
        contentView.addSubview(roleLabel)
        
        bubleView = UIView()
        bubleView.backgroundColor = UIColor(hex: 0xE1EBFC)
        bubleView.layer.cornerRadius = 4
        contentView.addSubview(bubleView)
        
        messageLabel = UILabel()
        messageLabel.textColor = UIColor(hex: 0x191919)
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(messageLabel)
    }
    
    func createConstraint() {
        avatarView.mas_makeConstraints { make in
            make?.top.equalTo()(5)
            make?.right.equalTo()(-14)
            make?.width.height().equalTo()(kAvatarHeight)
        }
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(avatarView)
            make?.right.equalTo()(avatarView.mas_left)?.offset()(-6)
        }
        roleLabel.mas_makeConstraints { make in
            make?.height.equalTo()(kRoleLabelHeight)
            make?.right.equalTo()(nameLabel.mas_left)?.offset()(-6)
            make?.centerY.equalTo()(nameLabel)
        }
        messageLabel.mas_makeConstraints { make in
            make?.right.equalTo()(-25)
            make?.top.equalTo()(avatarView.mas_bottom)?.offset()(17)
            make?.left.greaterThanOrEqualTo()(25)
            make?.bottom.equalTo()(self.contentView)?.offset()(-15)
        }
        bubleView.mas_makeConstraints { make in
            make?.left.equalTo()(messageLabel)?.offset()(-10)
            make?.right.equalTo()(messageLabel)?.offset()(10)
            make?.top.equalTo()(messageLabel)?.offset()(-9)
            make?.bottom.equalTo()(messageLabel)?.offset()(9)
        }
    }
}

