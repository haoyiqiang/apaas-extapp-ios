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
    private var pollDetails = Dictionary<Int,AgoraPollDetails>()
    private var items = [String]()
    
    /**Views**/
    private lazy var pollTitle: UILabel = {
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
        tab.isScrollEnabled = (pollDetails.count > 4)
        return tab
    }()
    
    init(title: String,
         items: [String],
         pollDetails: Dictionary<Int,AgoraPollDetails>) {
        self.title = title
        self.items = items
        self.pollDetails = pollDetails
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        addSubviews([pollTitle,resultTable])
        
        let size = pollTitle.text?.agora_size(font: .systemFont(ofSize: 13))
        pollTitle.mas_remakeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(20))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-20))
            make?.top.equalTo()(AgoraWidgetsFit.scale(25))
            make?.height.equalTo()(size?.height)
        }
        resultTable.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraWidgetsFit.scale(10))
            make?.right.equalTo()(AgoraWidgetsFit.scale(-10))
            make?.top.equalTo()(pollTitle.mas_bottom)?.offset()(AgoraWidgetsFit.scale(15))
            make?.bottom.equalTo()(AgoraWidgetsFit.scale(-15))
        }
    }
    
    func update(title: String,
                items: [String],
                pollDetails: Dictionary<Int,AgoraPollDetails>) {
        self.pollDetails = pollDetails
        self.items = items
        
        self.pollTitle.text = title
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
        return pollDetails.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "pollCell\(indexPath.row)"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? AgoraPollResultCell
        if cell == nil {
            cell = AgoraPollResultCell(style: .default,
                                         reuseIdentifier: reuseId)
        }
        
        guard items.count > indexPath.row ,
              let detail = pollDetails[indexPath.row] else {
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
