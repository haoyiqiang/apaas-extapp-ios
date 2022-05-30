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
    private var baseInfo: AgoraWidgetRequestKeys?
    
    // View Data
    private var state: AgoraPollViewState = .unselected {
        didSet {
            receiverView.state = state
            
            if state == .finished {
                updateViewFrame()
                receiverView.tableView.reloadData()
            }
        }
    }
    
    private var selectedMode: AgoraPollViewSelectedMode = .single {
        didSet {
            receiverView.selectedMode = selectedMode
        }
    }
    
    private var title: AgoraPollViewTitle?
    
    private var optionList: AgoraPollViewOptionList? {
        didSet {
            guard state != .finished,
                  let list = optionList  else {
                return
            }
            
            let hasSelected = list.items.contains(where: {$0.isSelected == true})
            
            state = (hasSelected ? .selected : .unselected)
        }
    }
    
    private var resultList: AgoraPollViewResultList?
    
    // View
    private let receiverView = AgoraPollReceiverView()
    
    // Config
    private let group = AgoraUIGroup()
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId,
                                       logId: widgetInfo.localUserInfo.userUuid)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
    }
    
    // MARK: widget callback
    public override func onLoad() {
        super.onLoad()
        initViews()
        initConstraints()
        
        updateRoomData()
        updateUserData()
        updateViewData()
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        updateRoomData()
        updateViewData()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }
    
    public override func onWidgetUserPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetUserPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        updateUserData()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }

    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        
        if let baseInfo = message.toRequestKeys() {
            serverAPI = AgoraPollServerAPI(baseInfo: baseInfo,
                                           roomId: info.roomInfo.roomUuid,
                                           uid: info.localUserInfo.userUuid,
                                           logTube: self)
        }
        
        if message == "hideSubmit" {
            receiverView.submitButton.isHidden = true
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
        
        view.backgroundColor = .clear
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
        var tableHeight: CGFloat = 0
        
        if state == .finished,
           let list = resultList {
            tableHeight = list.height
        } else if let list = optionList {
            tableHeight = list.height
        }
        
        guard let titleHeight = title?.titleSize.height else {
            return
        }
        
        receiverView.updateViewFrame(titleHeight: titleHeight,
                                     tableHeight: tableHeight)
        
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
   
        // title
        let titleFont = group.font.poll_label_font
        let limitWidth = receiverView.neededSize.width - group.frame.poll_title_label_horizontal_space - group.frame.poll_title_label_horizontal_space
        
        title = data.toViewTitle(font: titleFont,
                                 limitWidth: limitWidth)
        receiverView.titleLabel.text = title?.title
        
        // option
        let optionLabelFont: UIFont = group.font.poll_label_font
        let optionWidth = receiverView.neededSize.width
        
        let optionLabelInsets = UIEdgeInsets(top: group.frame.poll_option_label_vertical_space,
                                             left: group.frame.poll_option_label_left_space,
                                             bottom: group.frame.poll_option_label_vertical_space,
                                             right: group.frame.poll_option_label_right_space)
        
        optionList = data.toPollViewOptionList(optionFont: optionLabelFont,
                                               optionLabelInsets: optionLabelInsets,
                                               optionWidth: optionWidth)
        
        // result
        let resultLabelFont = group.font.poll_label_font
        let resultWidth = receiverView.neededSize.width
        
        let resultTitleLabelInsetsRight = group.frame.poll_result_value_label_width + group.frame.poll_result_label_horizontal_space
        
        let resultTitleLabelInsets = UIEdgeInsets(top: group.frame.poll_result_label_vertical_space,
                                                  left: group.frame.poll_result_label_horizontal_space,
                                                  bottom: group.frame.poll_result_label_vertical_space,
                                                  right: resultTitleLabelInsetsRight)
        
        resultList = data.toPollViewResultList(resultFont: resultLabelFont,
                                               resultTitleLabelInsets: resultTitleLabelInsets,
                                               resultWidth: resultWidth)
        
        // mode
        selectedMode = data.toPollViewSelectedMode()
        
        updateViewFrame()
        
        receiverView.tableView.reloadData()
    }
    
    func findSelectedList() -> [Int] {
        var array = [Int]()
        
        guard let list = optionList else {
            return array
        }
        
        for index in 0..<list.items.count {
            let option = list.items[index]
            
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
        if state == .finished,
           let list = resultList {
            return list.items.count
        } else if let list = optionList {
            return list.items.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if state == .finished {
            let cellId = AgoraPollResultCell.cellId
            let resultCell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                           for: indexPath) as! AgoraPollResultCell
            
            let item = resultList!.items[indexPath.row]
            resultCell.titleLabel.text = item.title
            resultCell.resultLabel.text = item.result
            resultCell.resultProgressView.progress = item.percentage
            
            cell = resultCell
        } else {
            let cellId = AgoraPollOptionCell.cellId
            let optionCell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                           for: indexPath) as! AgoraPollOptionCell
            
            let item = optionList!.items[indexPath.row]
            optionCell.selectedMode = selectedMode
            optionCell.optionLabel.text = item.title
            optionCell.optionIsSelected = item.isSelected
            
            cell = optionCell
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        guard state != .finished,
              var list = optionList else {
            return
        }
        
        var reloadRows = [IndexPath]()
        
        if selectedMode == .single,
           let index = list.items.firstIndex(where: {$0.isSelected == true}) {
            var item = list.items[index]
            item.isSelected.toggle()
            list.items[index] = item
            
            let oldSelected = IndexPath(row: index,
                                        section: 0)
            
            reloadRows.append(oldSelected)
        }
        
        var item = list.items[indexPath.row]
        item.isSelected.toggle()
        list.items[indexPath.row] = item
        
        optionList = list
        
        reloadRows.append(indexPath)
        
        tableView.reloadRows(at: reloadRows,
                             with: .none)
    }
    
    public func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if state == .finished,
           let list = resultList {
            return list.items[indexPath.row].height
        } else if let list = optionList {
            return list.items[indexPath.row].height
        } else {
            return 0
        }
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
