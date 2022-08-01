//
//  AgoraCountdownTimeViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/15.
//

import AgoraUIBaseViews

class AgoraCountdownHeaderView: UIView, AgoraUIContentContainer {
    private let titleLabel = UILabel()
    private let lineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleLabelX: CGFloat = 8
        
        titleLabel.frame = CGRect(x: titleLabelX,
                                  y: 0,
                                  width: bounds.width - titleLabelX,
                                  height: bounds.height)
        
        lineLayer.frame = CGRect(x: 0,
                                 y: bounds.height,
                                 width: bounds.width,
                                 height: 1)
    }
    
    
    func initViews() {
        titleLabel.text = "fcr_countdown_timer_title".widgets_localized()
        
        addSubview(titleLabel)
        layer.addSublayer(lineLayer)
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        let config = UIConfig.counter
        backgroundColor = config.header.backgroundColor
        
        titleLabel.textColor = config.header.textColor
        titleLabel.font = config.header.font
        layer.cornerRadius = config.cornerRadius
        lineLayer.backgroundColor = config.header.sepLineColor.cgColor
    }
}

class AgoraCountdownColonLabel: UILabel, AgoraUIContentContainer {
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
        text = ":"
        textAlignment = .center
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        let config = UIConfig.counter.colon
        
        backgroundColor = .clear
        textColor = config.textColor
        font = config.font
    }
}
