//
//  SingleTimeView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/8.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

public class SingleTimeView: UIView {
    private lazy var bgImageView: UIImageView = {
        let v = UIImageView(image: GetWidgetImage(object: self,
                                                  "countdown_bg"))
        return v
    }()
    
    public lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "0"
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "4D6277")
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    public func turnColor(color: UIColor) {
        self.label.textColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bgImageView)
        bgImageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        addSubview(label)
        label.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
