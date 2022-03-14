//
//  AgoraPollWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/1.
//

import AgoraWidget
import AgoraLog
import Masonry
import Armin

@objcMembers public class AgoraPollWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    private var serverAPI: AgoraPollServerAPI?
    var logger: AgoraWidgetLogger

    // Origin Data
    private var roomData: AgoraPollRoomPropertiesData?
    private var userData: AgoraPollUserPropertiesData?
    private var baseInfo: AgoraAppBaseInfo?
    
    // View Data
    private var state: AgoraPollViewState = .unselected {
        didSet {
            receiverView.state = state
            
            if state == .finished {
                receiverView.tableView.reloadData()
            }
        }
    }
    
    private var selectedMode: AgoraPollViewSelectedMode = .single {
        didSet {
            receiverView.selectedMode = selectedMode
        }
    }
    
    private var optionList = [AgoraPollViewOption]() {
        didSet {
            guard state != .finished else {
                return
            }
            
            let hasSelected = optionList.contains(where: {$0.isSelected == true})
            
            state = (hasSelected ? .selected : .unselected)
        }
    }
    
    private var resultList = [AgoraPollViewResult]()
    
    // View
    private let receiverView = AgoraPollReceiverView()
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
    }
    
    // MARK: widget callback
    public override func onWidgetDidLoad() {
        super.onWidgetDidLoad()
        initViews()
        initConstraints()
        
        updateRoomData()
        updateUserData()
        updateViewData()
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths)
        updateRoomData()
        updateViewData()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }
    
    public override func onWidgetUserPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        super.onWidgetUserPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths)
        updateUserData()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }

    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        if let baseInfo = message.toAppBaseInfo() {
            serverAPI = AgoraPollServerAPI(baseInfo: baseInfo,
                                           roomId: info.roomInfo.roomUuid,
                                           uid: info.localUserInfo.userUuid,
                                           logTube: self)
        }
        
        log(content: message,
            type: .info)
    }
    
    @objc func doButtonPressed(_ sender: UIButton) {
        submitSelectedList()
    }
}

private extension AgoraPollWidget {
    func initViews() {
        view.addSubview(receiverView)
        
        receiverView.tableView.delegate = self
        receiverView.tableView.dataSource = self
        
        receiverView.submitButton.addTarget(self,
                                            action: #selector(doButtonPressed(_:)),
                                            for: .touchUpInside)
        
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor(hexString: "#2F4192")?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 6
    }
    
    func initConstraints() {
        receiverView.mas_makeConstraints { (make) in
            make?.top.bottom()?.right()?.left()?.equalTo()(0)
        }
    }
    
    func updateViewFrame() {
        var rowCount: Int
        
        if state == .finished {
            rowCount = resultList.count
        } else {
            rowCount = optionList.count
        }
        
        let title = receiverView.titleLabel.text ?? ""
        
        receiverView.updateViewFrame(title: title,
                                     tableRowCount: rowCount)
        
        let size = ["width": receiverView.neededSize.width,
                    "height": receiverView.neededSize.height]
        
        guard let message = ["size": size].jsonString() else {
            return
        }
        
        sendMessage(message)
    }
}

private extension AgoraPollWidget {
    func updateRoomData() {
        guard let roomProps = info.roomProperties,
           let data = roomProps.toObj(AgoraPollRoomPropertiesData.self) else {
            return
        }
        
        roomData = data
    }
    
    func updateUserData() {
        guard let userProps = info.localUserProperties,
              let userData = userProps.toObj(AgoraPollUserPropertiesData.self),
              let data = roomData,
              userData.pollId == data.pollId else {
            return
        }
        
        self.userData = userData
    }
    
    func updateViewData() {
        guard let data = roomData else {
            return
        }
        
        if let state = data.toPollViewState() { // finished
            self.state = state
        } else if let _ = userData { // submited
            self.state = .finished
        }
        
        resultList = data.toPollViewResultList()
        optionList = data.toPollViewOptionList(selectedList: userData?.selectIndex)
        
        selectedMode = data.toPollViewSelectedMode()
        receiverView.titleLabel.text = data.pollTitle
        
        updateViewFrame()
        
        receiverView.tableView.reloadData()
    }
    
    func findSelectedList() -> [Int] {
        var array = [Int]()
        
        for index in 0..<optionList.count {
            let option = optionList[index]
            
            guard option.isSelected else {
                continue
            }
            
            array.append(index)
        }
        
        return array
    }
    
    func submitSelectedList() {
        guard let data = roomData,
              let server = serverAPI else {
            return
        }
        
        let list = findSelectedList()
        
        server.submit(pollId: data.pollId,
                      selectList: list) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.state = .finished
        }
    }
}

extension AgoraPollWidget: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        if state == .finished {
            return resultList.count
        } else {
            return optionList.count
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if state == .finished {
            let cellId = AgoraPollResultCell.cellId
            let resultCell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                           for: indexPath) as! AgoraPollResultCell
            
            let item = resultList[indexPath.row]
            resultCell.titleLabel.text = item.title
            resultCell.resultLabel.text = item.result
            resultCell.resultProgressView.progress = item.percentage
            
            cell = resultCell
        } else {
            let cellId = AgoraPollOptionCell.cellId
            let optionCell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                           for: indexPath) as! AgoraPollOptionCell
            
            let item = optionList[indexPath.row]
            optionCell.selectedMode = selectedMode
            optionCell.optionLabel.text = item.title
            optionCell.optionIsSelected = item.isSelected
            
            cell = optionCell
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        guard state != .finished else {
            return
        }
        
        var reloadRows = [IndexPath]()
        
        if selectedMode == .single,
           let index = optionList.firstIndex(where: {$0.isSelected == true}) {
            var item = optionList[index]
            item.isSelected.toggle()
            optionList[index] = item
            
            let oldSelected = IndexPath(row: index,
                                        section: 0)
            
            reloadRows.append(oldSelected)
        }
        
        var item = optionList[indexPath.row]
        item.isSelected.toggle()
        optionList[indexPath.row] = item
        
        reloadRows.append(indexPath)
        
        tableView.reloadRows(at: reloadRows,
                             with: .none)
    }
}

extension AgoraPollWidget: ArLogTube {
    public func log(info: String,
                    extra: String?) {
        log(content: info,
            extra: extra,
            type: .info)
    }
    
    public func log(warning: String,
                    extra: String?) {
        log(content: warning,
            extra: extra,
            type: .info)
    }
    
    public func log(error: ArError,
                    extra: String?) {
        log(content: error.localizedDescription,
            extra: extra,
            type: .info)
    }
}
