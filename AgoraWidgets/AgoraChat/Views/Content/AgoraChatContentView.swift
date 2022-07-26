//
//  AgoraChatMessageListView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/7/17.
//

import AgoraUIBaseViews
import SDWebImage
import UIKit

class AgoraChatContentView: UIView {
    /**views**/
    private lazy var messageListView = UITableView(frame: .zero,
                                                   style: .plain)
    
    private lazy var annoucementLabel = UILabel(frame: .zero)
    
    private lazy var nilImageView = UIImageView(frame: .zero)
    private lazy var nilLabel = UILabel(frame: .zero)
    
    /**data**/
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
                updateContentType()
                return
            }
            annoucementLabel.text = announcementText
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
        
        addSubviews([messageListView,
                     annoucementLabel,
                     nilImageView,
                     nilLabel])
        
        let config = UIConfig.agoraChat
        messageListView.agora_enable = config.message.enable
        messageListView.agora_visible = false
        
        annoucementLabel.agora_enable = config.announcement.enable
        annoucementLabel.agora_visible = false
        
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
    }
    
    func updateViewProperties() {
        let config = UIConfig.agoraChat
        
        messageListView.backgroundColor = config.backgroundColor
        
        annoucementLabel.font = config.announcement.labelFont
        annoucementLabel.textColor = config.announcement.labelColor
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
            updateTextMessageCell(cell: cell,
                                  model: model)
            return cell
        case .image(let model):
            let id = (model.isLocal) ? AgoraChatCommonMessageCell.sendId : AgoraChatCommonMessageCell.receiveId
            let cell = tableView.dequeueReusableCell(withIdentifier: id,
                                                     for: indexPath) as! AgoraChatCommonMessageCell
            updateImageMessageCell(cell: cell,
                                   model: model)
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
            guard let _ = annoucementLabel.text else {
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
        
        if let image = model.image {
            cell.messageImageView.image = image
            let size = cell.sizeWithImage(image)
            cell.messageImageView.size = size
        } else {
            let url = URL(string: model.imageRemoteUrl)
            cell.messageImageView.sd_setImage(with: url) { image, error, cacheType, url in
                guard error == nil,
                      let downloadImage = image else {
                    let brokenImage = UIConfig.agoraChat.picture.brokenImage
                    cell.messageImageView.image = brokenImage
                    let size = cell.sizeWithImage(brokenImage)
                    cell.messageImageView.size = size
                    return
                }
                cell.messageImageView.image = downloadImage
                let size = cell.sizeWithImage(downloadImage)
                cell.messageImageView.size = size
            }
        }
        
        cell.updateFrame()
    }
    
    func updateTextMessageCell(cell: AgoraChatCommonMessageCell,
                               model: AgoraChatTextMessageModel) {
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
        cell.messageLabel.agora_visible = true
        cell.bubleView.agora_visible = true
        cell.messageImageView.agora_visible = false
        
        cell.messageLabel.text = model.text
        cell.updateFrame()
    }
    
    func updateNoticeMessageCell(cell: AgoraChatNoticeMessageCell,
                                 notice: String) {
        cell.noticeLabel.text = notice
      }
}
