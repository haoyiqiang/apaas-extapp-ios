//
//  AgoraPollResultView.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/3.
//

import Foundation

class AgoraPollResultView: UIView {
    /**Data**/
    private var title = ""
    private var pollingDetails = Dictionary<Int,AgoraPollDetails>()
    private var items = [String]()
    
    /**Views**/
    private lazy var pollingTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = title
        return label
    }()
    private lazy var resultTable: UITableView = {
        let tab = UITableView()
        tab.delegate = self
        tab.dataSource = self
        tab.register(cellWithClass: AgoraPollResultCell.self)
        tab.separatorStyle = .none
        tab.isScrollEnabled = (pollingDetails.count > 4)
        return tab
    }()
    
    init(title: String,
         items: [String],
         pollingDetails: Dictionary<Int,AgoraPollDetails>) {
        self.title = title
        self.items = items
        self.pollingDetails = pollingDetails
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        addSubviews([pollingTitle,resultTable])
        
        let size = pollingTitle.text?.agora_size(font: .systemFont(ofSize: 13))
        pollingTitle.mas_remakeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(20))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-20))
            make?.top.equalTo()(AgoraWidgetsFit.scale(25))
            make?.height.equalTo()(size?.height)
        }
        resultTable.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-10))
            make?.top.equalTo()(pollingTitle.mas_bottom)?.offset()(AgoraWidgetsFit.scale(15))
            make?.bottom.equalTo()(AgoraWidgetsFit.scale(-15))
        }
    }
    
    func update(title: String,
                items: [String],
                pollingDetails: Dictionary<Int,AgoraPollDetails>) {
        self.pollingDetails = pollingDetails
        self.items = items
        
        self.pollingTitle.text = title
        self.resultTable.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension AgoraPollResultView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return pollingDetails.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "PollingCell\(indexPath.row)"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? AgoraPollResultCell
        if cell == nil {
            cell = AgoraPollResultCell(style: .default,
                                         reuseIdentifier: reuseId)
        }
        
        guard items.count > indexPath.row ,
              let detail = pollingDetails[indexPath.row] else {
            return cell!
        }
        cell?.updateInfo(AgoraPollCellResultInfo(index: indexPath.row,
                                                   itemText: items[indexPath.row],
                                                   count: detail.num,
                                                   percent: detail.percentage))
        
        cell?.selectionStyle = .none
        return cell!
    }
}
