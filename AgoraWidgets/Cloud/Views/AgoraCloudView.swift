//
//  AgoraCloudView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews

class AgoraCloudView: UIView {
    let topView = AgoraCloudTopView(frame: .zero)
    let listView = AgoraCloudListView(frame: .zero)
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        backgroundColor = .white
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        addSubview(topView)
        addSubview(listView)
    }
    
    private func initLayout() {
        topView.mas_makeConstraints { make in
            make?.left.and().right().and().top().equalTo()(self)
            make?.height.equalTo()(60)
        }
        
        listView.mas_makeConstraints { make in
            make?.left.and().right().and().bottom().equalTo()(self)
            make?.top.equalTo()(self.topView.mas_bottom)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        endEditing(true)
    }
}


