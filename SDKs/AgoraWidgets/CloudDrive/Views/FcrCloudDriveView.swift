//
//  AgoraCloudView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews

class FcrCloudDriveView: UIView {
    private(set) var topView = FcrCloudDriveTopView(frame: .zero)
    private(set) var listView = UITableView(frame: .zero)
        
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
extension FcrCloudDriveView: AgoraUIContentContainer {
    func initViews() {
        listView.contentInset = .zero
        listView.tableFooterView = UIView()
        listView.separatorInset = .zero
        listView.rowHeight = 43
        
        listView.register(FcrCloudDriveCell.self,
                          forCellReuseIdentifier: FcrCloudDriveCell.cellId)
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
