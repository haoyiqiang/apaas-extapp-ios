//
//  AgoraChatMessageListView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import AgoraUIBaseViews
import SDWebImage
import UIKit

protocol AgoraChatContentViewDelegate: NSObjectProtocol {
    func didTouchAnnouncement()
}

class AgoraChatContentView: UIView {
    /**views**/
    private lazy var messageListView = UITableView(frame: .zero,
                                                   style: .plain)
    
    private lazy var annoucementLabel = UILabel(frame: .zero)
    private lazy var annoucementButton = UIButton(type: .custom)
    
    private lazy var nilImageView = UIImageView(frame: .zero)
    private lazy var nilLabel = UILabel(frame: .zero)
    
    /**data**/
    weak var delegate: AgoraChatContentViewDelegate?
    var messageDataSource = [AgoraChatMessageViewType]() {
        didSet {
            updateMessageList()
            updateContentType()
        }
    }
    
    var contentType: AgoraChatContentType = .messages {
        didSet {
            updateContentType()
        }
    }
    
    var announcementText: String? {
        didSet {
            guard let text = announcementText,
                  text.count > 0 else {
                annoucementLabel.text = nil
                annoucementButton.setTitle(nil,
                                           for: .normal)
                updateContentType()
                return
            }
            annoucementLabel.text = announcementText
            annoucementButton.setTitle(announcementText,
                                       for: .normal)
            updateContentType()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraChatContentView: AgoraUIContentContainer {
    func initViews() {
        messageListView.delegate = self
        messageListView.dataSource = self
        messageListView.tableFooterView = UIView()
        messageListView.estimatedRowHeight = 60
        messageListView.estimatedSectionHeaderHeight = 0
        messageListView.estimatedSectionFooterHeight = 0
        messageListView.separatorInset = .zero
        messageListView.separatorStyle = .none
        messageListView.allowsMultipleSelection = false
        messageListView.allowsSelection = false
        messageListView.register(AgoraChatCommonMessageCell.self,
                                 forCellReuseIdentifier: AgoraChatCommonMessageCell.sendId)
        messageListView.register(AgoraChatCommonMessageCell.self,
                                 forCellReuseIdentifier: AgoraChatCommonMessageCell.receiveId)
        messageListView.register(AgoraChatNoticeMessageCell.self,
                                 forCellReuseIdentifier: AgoraChatNoticeMessageCell.id)
        
        nilLabel.textAlignment = .center
        
        annoucementLabel.textAlignment = .left
        annoucementLabel.numberOfLines = 0
        
        annoucementButton.titleLabel?.numberOfLines = 1
        annoucementButton.titleLabel?.lineBreakMode = .byTruncatingTail
        annoucementButton.imageView?.contentMode = .scaleAspectFit
        annoucementButton.addTarget(self,
                                    action: #selector(onClickAnnouncement(_:)),
                                    for: .touchUpInside)
        
        addSubviews([messageListView,
                     annoucementLabel,
                     nilImageView,
                     nilLabel,
                     annoucementButton])
        
        let config = UIConfig.agoraChat
        messageListView.agora_enable = config.message.enable
        messageListView.agora_visible = false
        
        annoucementLabel.agora_enable = config.announcement.enable
        annoucementLabel.agora_visible = false
        annoucementButton.agora_enable = config.announcement.enable
        annoucementButton.agora_visible = false
        
        nilImageView.agora_visible = true
        nilLabel.agora_visible = true
    }
    
    func initViewFrame() {
        messageListView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
        
        nilImageView.mas_makeConstraints { make in
            make?.centerX.centerY().equalTo()(self);
            make?.width.equalTo()(80)
            make?.height.equalTo()(80)
        }
        
        nilLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(nilImageView)
            make?.top.equalTo()(nilImageView.mas_bottom)
            make?.width.equalTo()(self);
            make?.height.equalTo()(20);
        }
        
        annoucementLabel.mas_makeConstraints { make in
            make?.center.equalTo()(self)
            make?.width.height().lessThanOrEqualTo()(self)?.offset()(-14)
        }
        
        annoucementButton.mas_makeConstraints { make in
            make?.width.left().top().equalTo()(self)
            make?.height.equalTo()(24)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.agoraChat
        
        messageListView.backgroundColor = config.backgroundColor
        
        annoucementLabel.font = config.announcement.labelFont
        annoucementLabel.textColor = config.announcement.labelColor
        
        annoucementButton.backgroundColor = config.announcement.buttonBackgroundColor
        annoucementButton.titleLabel?.font = config.announcement.buttonTitleFont
        annoucementButton.setTitleColorForAllStates(config.announcement.buttonTitleColor)
        annoucementButton.setImage(config.announcement.buttonImage,
                                   for: .normal)
    }
}

// MARK: - table view
extension AgoraChatContentView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messageDataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = messageDataSource[indexPath.row]
        
        switch type {
        case .text(let model):
            let id = (model.isLocal) ? AgoraChatCommonMessageCell.sendId : AgoraChatCommonMessageCell.receiveId
            let cell = tableView.dequeueReusableCell(withIdentifier: id,
                                                     for: indexPath) as! AgoraChatCommonMessageCell
            updateMessageCellBaseInfo(cell: cell,
                                      model: model,
                                      isText: true)
            
            cell.messageLabel.text = model.text
            cell.updateFrame()
            return cell
        case .image(let model):
            let id = (model.isLocal) ? AgoraChatCommonMessageCell.sendId : AgoraChatCommonMessageCell.receiveId
            let cell = tableView.dequeueReusableCell(withIdentifier: id,
                                                     for: indexPath) as! AgoraChatCommonMessageCell
            updateMessageCellBaseInfo(cell: cell,
                                      model: model,
                                      isText: false)
            
            if let image = model.image {
                cell.messageImageView.image = image
                let size = cell.sizeWithImage(image)
                cell.messageImageView.size = size
                cell.updateFrame()
            } else {
                let url = URL(string: model.imageRemoteUrl)
                let brokenImage = UIConfig.agoraChat.picture.brokenImage
                cell.messageImageView.sd_setImage(with: url,
                                                  placeholderImage: brokenImage) { downloadImage, error, cacheType, url in
                    cell.messageImageView.image = downloadImage
                    let size = cell.sizeWithImage(downloadImage)
                    cell.messageImageView.size = size
                    cell.updateFrame()
                    
                    tableView.reloadRows(at: [indexPath],
                                         with: .none)
                }
            }
            return cell
        case .notice(let noticeString):
            let cell = tableView.dequeueReusableCell(withIdentifier: AgoraChatNoticeMessageCell.id,
                                                     for: indexPath) as! AgoraChatNoticeMessageCell
            updateNoticeMessageCell(cell: cell,
                                    notice: noticeString)
            return cell
        }
    }
}

// MARK: - private
private extension AgoraChatContentView {
    func updateContentType() {
        let config = UIConfig.agoraChat
        switch contentType {
        case .messages:
            annoucementButton.agora_visible = (annoucementButton.titleForNormal != nil)
            
            guard messageDataSource.count > 0 else {
                nilImageView.image = config.message.nilImage
                
                nilLabel.text = config.message.nilText
                
                nilLabel.font = config.message.nilLabelFont
                nilLabel.textColor = config.message.nilLabelColor
                
                nilImageView.agora_visible = true
                nilLabel.agora_visible = true
                
                messageListView.agora_visible = false
                annoucementLabel.agora_visible = false
                return
            }
            nilImageView.agora_visible = false
            nilLabel.agora_visible = false
            
            messageListView.agora_visible = true
            annoucementLabel.agora_visible = false
        case .announcement:
            annoucementButton.agora_visible = false
            
            guard let _ = announcementText else {
                nilImageView.image = config.announcement.nilImage
                nilLabel.text = config.announcement.nilText
                
                nilLabel.font = config.announcement.nilLabelFont
                nilLabel.textColor = config.announcement.nilLabelColor
                
                nilImageView.agora_visible = true
                nilLabel.agora_visible = true
                
                messageListView.agora_visible = false
                annoucementLabel.agora_visible = false
                return
            }
            nilImageView.agora_visible = false
            nilLabel.agora_visible = false
            
            messageListView.agora_visible = false
            annoucementLabel.agora_visible = true
        }
    }
    
    func updateMessageList() {
        if messageDataSource.count >= 150 {
            messageDataSource.removeSubrange(0..<50)
        }
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.messageListView.reloadData {
                let index = IndexPath(row: self.messageDataSource.count - 1, section: 0)
                self.messageListView.scrollToRow(at: index,
                                                 at: .bottom,
                                                 animated: true)
            }
        }
    }
    
    func updateImageMessageCell(cell: AgoraChatCommonMessageCell,
                                model: AgoraChatImageMessageModel) {
        cell.nameLabel.text = model.userName
        if model.userRole.count > 0 {
            cell.roleLabel.agora_visible = true
            cell.roleLabel.text = model.userRole
        } else {
            cell.roleLabel.agora_visible = false
        }
        
        if let avatarUrl = model.avatar,
           let url = URL(string: avatarUrl) {
            cell.avatarView.sd_setImage(with: url)
        }
        cell.messageLabel.agora_visible = false
        cell.bubleView.agora_visible = false
        cell.messageImageView.agora_visible = true
    }
    func updateMessageCellBaseInfo(cell: AgoraChatCommonMessageCell,
                                   model: AgoraChatMessageModel,
                                   isText: Bool) {
        cell.nameLabel.text = model.userName
        
        if model.userRole.count > 0 {
            cell.roleLabel.agora_visible = true
            cell.roleLabel.text = model.userRole
        } else {
            cell.roleLabel.agora_visible = false
        }
        
        if let avatarUrl = model.avatar,
           let url = URL(string: avatarUrl) {
            cell.avatarView.sd_setImage(with: url)
        }
        
        cell.messageLabel.agora_visible = isText
        cell.bubleView.agora_visible = isText
        cell.messageImageView.agora_visible = !isText
    }
    
    func updateNoticeMessageCell(cell: AgoraChatNoticeMessageCell,
                                 notice: String) {
        cell.noticeLabel.text = notice
      }
    
    // Actions
    @objc func onClickAnnouncement(_ sender: UIButton) {
        delegate?.didTouchAnnouncement()
    }
}
