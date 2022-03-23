//
//  AgoraRtmIMSendBar.swift
//  AgoraWidgets
//
//  Created by Jonathan on 2021/12/16.
//

import UIKit

protocol AgoraRtmIMSendBarDelegate: NSObjectProtocol {
    
    func onClickInputMessage()
    
    func onClickInputEmoji()
}

class AgoraRtmIMSendBar: UIView {
    
    weak var delegate: AgoraRtmIMSendBarDelegate?
    
    private var topLine: UIView!
    
    private var infoLabel: UILabel!
    
    private var emojiButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isMute(_ isMute: Bool) {
        if isMute {
            infoLabel.text = "fcr_rtm_im_silence_holder".ag_localizedIn("AgoraWidgets")
        } else {
            infoLabel.text = "fcr_rtm_im_input_placeholder".ag_localizedIn("AgoraWidgets")
        }
        
        isUserInteractionEnabled = !isMute
    }
}
// MARK: - Actions
private extension AgoraRtmIMSendBar {
    
    @objc func onClickSendMessage() {
        self.delegate?.onClickInputMessage()
    }
    
    @objc func onClickSendEmoji(_ sender: UIButton) {
        self.delegate?.onClickInputEmoji()
    }
}
// MARK: - Creations
private extension AgoraRtmIMSendBar {
    func createViews() {
        backgroundColor = UIColor(hex: 0xF9F9FC)
        
        topLine = UIView()
        topLine.backgroundColor = UIColor(hex: 0xECECF1)
        addSubview(topLine)
        
        let tap = UITapGestureRecognizer.init(target: self,
                                              action: #selector(onClickSendMessage))
        self.addGestureRecognizer(tap)
        
        infoLabel = UILabel()
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        infoLabel.textColor = UIColor(hex: 0x7D8798)
        infoLabel.text = "fcr_rtm_im_input_placeholder".ag_localizedIn("AgoraWidgets")
        addSubview(infoLabel)
        
        emojiButton = UIButton(type: .custom)
        emojiButton.setImage(UIImage.ag_imageNamed("ic_rtm_keyboard_emoji",
                                                   in: "AgoraWidgets"), for: .normal)
        emojiButton.addTarget(self,
                              action: #selector(onClickSendMessage),
                              for: .touchUpInside)
        addSubview(emojiButton)
    }
    
    func createConstraint() {
        topLine.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(1)
        }
        emojiButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(34)
            make?.left.equalTo()(7)
            make?.centerY.equalTo()(0)
        }
        infoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(emojiButton.mas_right)?.offset()(2)
            make?.centerY.equalTo()(0)
        }
    }
}
