//
//  AgoraCloudView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews

class AgoraCloudView: UIView {
    private(set) lazy var topView = AgoraCloudTopView(frame: .zero)
    private(set) lazy var listView = UITableView(frame: .zero)
        
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
extension AgoraCloudView: AgoraUIContentContainer {
    func initViews() {
        listView.contentInset = .zero
        listView.tableFooterView = UIView()
        listView.separatorInset = .zero
        
        listView.register(AgoraCloudCell.self,
                          forCellReuseIdentifier: AgoraCloudCell.cellId)
        addSubview(topView)
        addSubview(listView)
    }
    
    func initViewFrame() {
        topView.mas_makeConstraints { make in
            make?.left.and().right().and().top().equalTo()(self)
            make?.height.equalTo()(90)
        }
        
        listView.mas_makeConstraints { make in
            make?.left.and().right().and().bottom().equalTo()(self)
            make?.top.equalTo()(self.topView.mas_bottom)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.cloudStorage
        backgroundColor = config.backgroundColor
        listView.backgroundColor = config.cell.backgroundColor
        layer.cornerRadius = config.cornerRadius
        layer.masksToBounds = true
    }
}
