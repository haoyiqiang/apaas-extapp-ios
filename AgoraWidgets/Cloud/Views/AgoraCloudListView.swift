//
//  AgoraCloudContentView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import AgoraUIBaseViews
import Masonry

/**
 AgoraCloudListView
 Data更新：文件列表
 
 通知外部：
 1. 选择cell->文件
 */

class AgoraCloudCell: UITableViewCell {
    
    private let iconImageView = UIImageView(frame: .zero)
    private let nameLabel = UILabel()
    
    private var info: AgoraCloudCellInfo? {
        didSet {
            guard let cellInfo = info else {
                return
            }
            iconImageView.image = GetWidgetImage(object: self,
                                                 cellInfo.imageName)
            nameLabel.text = cellInfo.name
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        createViews()
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews() {
        nameLabel.textColor = UIColor(hex: 0x191919)
        nameLabel.font = .systemFont(ofSize: 13)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
    }
    
    private func createConstraints() {
        iconImageView.mas_makeConstraints { make in
            make?.height.width().equalTo()(22)
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(self.contentView)
        }
        
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.iconImageView.mas_right)?.offset()(9)
            make?.centerY.equalTo()(self.contentView)
        }
    }
        
    func update(_ cellInfo: AgoraCloudCellInfo?) {
        self.info = cellInfo
    }
}

protocol AgoraCloudListViewDelegate: NSObjectProtocol {
    func agoraCloudListViewDidSelectedIndex(index: Int)
}

class AgoraCloudListView: UIView {
    weak var listDelegate: AgoraCloudListViewDelegate?
    
    /**Views*/
    private let headerView = UIView()
    private let lineLayer = CALayer()
    private let listTableView = UITableView(frame: .zero,
                                            style: .plain)
    
    private var infos = [AgoraCloudCellInfo]() {
        didSet {
            self.listTableView.reloadData()
        }
    }
    
    private let cellId = "AgoraCloudCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        createConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(x: 0,
                                 y: 30,
                                 width: bounds.width,
                                 height: 1)
    }

    func update(infos: [AgoraCloudCellInfo]?) {
        self.infos = infos ?? [AgoraCloudCellInfo]()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AgoraCloudListView: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                             for: indexPath) as! AgoraCloudCell
        cell.update(infos[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        listDelegate?.agoraCloudListViewDidSelectedIndex(index: indexPath.row)
    }
}

// MARK: - private
extension AgoraCloudListView {
    func createViews() {
        // header view
        let nameLabel = UILabel()
        
        headerView.backgroundColor = UIColor(hex: 0xF9F9FC)
        nameLabel.text = GetWidgetLocalizableString(object: self,
                                                    key: "CloudFileName")
        
        nameLabel.textColor = UIColor(hex: 0x191919)
        nameLabel.font = .systemFont(ofSize: 13)
        lineLayer.backgroundColor = UIColor(hex: 0xEEEEF7)?.cgColor
        
        headerView.addSubview(nameLabel)
        headerView.layer.addSublayer(lineLayer)
        
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.headerView)
            make?.left.equalTo()(self.headerView)?.offset()(14)
        }
        
        // table
        listTableView.contentInset = .zero
        listTableView.backgroundColor = .white
        listTableView.tableFooterView = UIView()
        listTableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        listTableView.register(AgoraCloudCell.self,
                 forCellReuseIdentifier: cellId)
        listTableView.dataSource = self
        listTableView.delegate = self
        
        addSubviews([headerView,listTableView])
    }
    
    func createConstraint() {
        headerView.mas_makeConstraints { make in
            make?.top.left().and().right().equalTo()(self)
            make?.height.equalTo()(30)
        }
        
        listTableView.mas_makeConstraints { make in
            make?.top.equalTo()(headerView.mas_bottom)
            make?.left.right().bottom().equalTo()(0)
        }
    }
}
