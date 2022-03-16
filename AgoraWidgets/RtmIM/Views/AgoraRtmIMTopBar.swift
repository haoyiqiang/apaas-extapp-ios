//
//  AgoraRtmIMTopBar.swift
//  AgoraWidgets
//
//  Created by Jonathan on 2021/12/16.
//

import UIKit

class AgoraRtmIMTopBar: UIView {
    
    private var titleLabel: UILabel!
    
    private var lineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(hex: 0x191919)
        titleLabel.text = "fcr_rtm_im_title".ag_localizedIn("AgoraWidgets")
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(titleLabel)
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(16)
            make?.right.greaterThanOrEqualTo()(-16)
        }
        
        lineView = UIView()
        lineView.backgroundColor = UIColor(hex: 0xECECF1)
        addSubview(lineView)
        lineView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            make?.height.equalTo()(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}
