//
//  AgoraCountdownTimeViews.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/15.
//

import UIKit

class AgoraCountdownHeaderView: UIView {
    private let titleLabel = UILabel()
    private let lineLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    private func initViews() {
        titleLabel.text = "Countdown_title".ag_widget_localized()
        titleLabel.textColor = UIColor(hexString: "#191919")
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        lineLayer.backgroundColor = UIColor(hexString: "#EEEEF7")?.cgColor
        
        addSubview(titleLabel)
        layer.addSublayer(lineLayer)
        
        backgroundColor = .white
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
}

class AgoraCountdownColonLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        text = ":"
        textColor = UIColor(hexString: "4D6277")
        font = UIFont.boldSystemFont(ofSize: 10)
        backgroundColor = .clear
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
