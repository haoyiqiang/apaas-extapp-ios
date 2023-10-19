//
//  FcrCloudDriveBottomView.swift
//  AgoraWidgets
//
//  Created by Cavan on 2023/10/16.
//

import AgoraUIBaseViews

class FcrCloudDriveBottomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let `imageView` = imageView,
              let label = titleLabel,
              let text = label.text
        else {
            return
        }
        
        let imageWidth: CGFloat = 20
        let imageHeight: CGFloat = 20
        
        let horizontalSpace: CGFloat = 6
        
        let textHeight = bounds.height
        let textWidth = text.agora_size(font: label.font,
                                        height: textHeight).width
        
        let contentWidth = (imageWidth + horizontalSpace + textWidth)
        
        let imageX = (bounds.width - contentWidth) * 0.5
        let imageY = (bounds.height - imageHeight) * 0.5
        
        let imageFrame = CGRect(x: imageX,
                                y: imageY,
                                width: imageWidth,
                                height: imageHeight)
        
        imageView.frame = imageFrame
        
        
        let textX = imageFrame.maxX + horizontalSpace
        let textY: CGFloat = 0
        
        let textFrame = CGRect(x: textX,
                               y: textY,
                               width: textWidth,
                               height: textHeight)
        
        label.frame = textFrame
    }
}

class FcrCloudDriveBottomView: UIView, AgoraUIContentContainer {
    enum State {
        case upload, delete
    }
    
    private let line = UIView(frame: .zero)
    
    let uploadImageButton = FcrCloudDriveBottomButton(frame: .zero)
    let uploadFileButton = FcrCloudDriveBottomButton(frame: .zero)
    let questionButton = UIButton(frame: .zero)
    let deleteButton = FcrCloudDriveBottomButton(frame: .zero)
    
    var state = State.upload {
        didSet {
            guard oldValue != state else {
                return
            }
            
            updateViews(with: state)
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
    
    func initViews() {
        addSubview(uploadImageButton)
        addSubview(uploadFileButton)
        addSubview(questionButton)
        addSubview(line)
        addSubview(deleteButton)
        
        layer.shadowColor = FcrWidgetUIColorGroup.containerShadowColor.cgColor
        layer.shadowOpacity = FcrWidgetUIColorGroup.shadowOpacity
        layer.shadowOffset = FcrWidgetUIColorGroup.containerShadowOffset
        
        uploadImageButton.titleLabel?.font = FcrWidgetUIFontGroup.font12
        uploadFileButton.titleLabel?.font = FcrWidgetUIFontGroup.font12
        deleteButton.titleLabel?.font = FcrWidgetUIFontGroup.font12
        
        updateViews(with: state)
    }
    
    func initViewFrame() {
        uploadFileButton.mas_makeConstraints { make in
            make?.right.equalTo()(uploadImageButton.mas_left)
            make?.width.equalTo()(uploadImageButton.mas_width)
            make?.top.left().bottom().equalTo()(0)
        }
        
        uploadImageButton.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(0)
        }
        
        questionButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.width.equalTo()(questionButton.mas_height)
        }
        
        line.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(1)
            make?.top.equalTo()(8)
            make?.bottom.equalTo()(-8)
        }
        
        deleteButton.mas_makeConstraints { make in
            make?.left.top().right().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        line.backgroundColor = FcrWidgetUIColorGroup.systemDividerColor
        
        questionButton.setImage(UIImage.widgets_image("cloud_question"),
                                for: .normal)
        
        // Upload file
        uploadFileButton.setImage(UIImage.widgets_image("cloud_upload_file"),
                                  for: .normal)
        
        uploadFileButton.setTitle("fcr_cloud_upload_file".widgets_localized(),
                                  for: .normal)
        
        uploadFileButton.setTitleColor(FcrWidgetUIColorGroup.textLevel1Color,
                                       for: .normal)
        
        uploadFileButton.backgroundColor = FcrWidgetUIColorGroup.systemForegroundColor
        
        // Upload image
        uploadImageButton.setImage(UIImage.widgets_image("cloud_upload_image"),
                                   for: .normal)
        
        uploadImageButton.setTitle("fcr_cloud_upload_pictures".widgets_localized(),
                                   for: .normal)
        
        uploadImageButton.setTitleColor(FcrWidgetUIColorGroup.textLevel1Color,
                                        for: .normal)
        
        uploadImageButton.backgroundColor = FcrWidgetUIColorGroup.systemForegroundColor
        
        // Delete
        deleteButton.setImage(UIImage.widgets_image("cloud_delete"),
                              for: .normal)
        
        deleteButton.setTitle("delete",
                              for: .normal)
        
        deleteButton.setTitleColor(FcrWidgetUIColorGroup.textLevel1Color,
                                   for: .normal)
        
        deleteButton.backgroundColor = FcrWidgetUIColorGroup.systemForegroundColor
    }
    
    private func updateViews(with state: State) {
        switch state {
        case .upload: deleteButton.isHidden = true
        case .delete: deleteButton.isHidden = false
        }
    }
}
