//
//  AgoraPopupQuizWidget.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/5.
//

import AgoraWidget
import AgoraLog
import Armin
import UIKit

@objcMembers public class AgoraPopupQuizWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    private var serverAPI: AgoraPopupQuizServerAPI?
    private var timer: Timer?
    var logger: AgoraWidgetLogger
    
    // View
    private let contentView = AgoraPopupQuizView() // for mask shadowo
    
    // Origin Data
    private var baseInfo: AgoraAppBaseInfo?
    
    private var roomData: AgoraPopupQuizRoomPropertiesData?
    
    private var objectCreateTimestamp: Int64?
    private var currentTimestamp: Int64 = 0 { // second
        didSet {
            let timeString = currentTimestamp.formatStringHMS
            contentView.topView.update(timeString: timeString)
        }
    }
    
    // View Data
    private var optionList = [AgoraPopupQuizOption]() {
        didSet {
            if let _ = optionList.first(where: {$0.isSelected}) {
                selectorState = .selected
            } else {
                selectorState = .unselected
            }
        }
    }
    
    private var resultList = [AgoraPopupQuizResult]()
    
    private var selectorState: AgoraPopupQuizState = .unselected {
        didSet {
            contentView.selectorState = selectorState
            contentView.optionCollectionView.reloadData()
        }
    }
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
    }
    
    public override func onWidgetDidLoad() {
        super.onWidgetDidLoad()
        
        createViews()
        createConstraint()
        initRoomData()
        updateViewFrame()
    }
    
    public override func onMessageReceived(_ message: String) {
        super.onMessageReceived(message)
        if let info = message.toAppBaseInfo() {
            baseInfo = info
        }
        
        if let timestamp = message.toSyncTimestamp() {
            objectCreateTimestamp = timestamp
            initTime()
            initServerAPI()
        }
        
        log(content: message,
            type: .info)
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths)
        updateRoomData()
        updateViewFrame()
        
        log(content: properties.jsonString() ?? "nil",
            extra: cause?.jsonString(),
            type: .info)
    }
    
    @objc func doButtonPressed(_ sender: UIButton) {
        switch selectorState {
        case .selected:
            submitAnswer()
        case .changing:
            selectorState = .selected
        default:
            break
        }
    }
    
    deinit {
        stopTimer()
    }
}

// MARK: - View
private extension AgoraPopupQuizWidget {
    func createViews() {
        selectorState = .unselected
        
        view.addSubview(contentView)
       
        contentView.optionCollectionView.dataSource = self
        contentView.optionCollectionView.delegate = self
        
        contentView.resultTableView.dataSource = self
        
        contentView.button.addTarget(self,
                                     action: #selector(doButtonPressed(_:)),
                                     for: .touchUpInside)
        
        view.layer.shadowColor = UIColor(hexString: "#2F4192")?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 6
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { (make) in
            make?.top.left()?.right()?.bottom()?.equalTo()(0)
        }
    }
    
    func updateViewFrame() {
        var size: [String: Any]
        
        if selectorState != .finished {
            contentView.updateUnfinishedViewFrame(optionCount: optionList.count)
            
            size = ["width": contentView.unfinishedNeededSize.width,
                    "height": contentView.unfinishedNeededSize.height]
        } else {
            size = ["width": contentView.finishedNeededSize.width,
                    "height": contentView.finishedNeededSize.height]
        }
        
        guard let message = ["size": size].jsonString() else {
            return
        }
        
        sendMessage(message)
    }
}

// MAKR: - Data
private extension AgoraPopupQuizWidget {
    func initRoomData() {
        guard let roomProperties = info.roomProperties,
              let data = roomProperties.toObj(AgoraPopupQuizRoomPropertiesData.self) else {
            return
        }
        
        roomData = data
        
        if let state = data.toViewSelectorState() {
            selectorState = state // .end
            initResultList()
        } else {
            initOptionList()
        }
        
        initTime()
        initServerAPI()
    }
    
    func initServerAPI() {
        guard let keys = baseInfo,
              let extra = roomData else {
            return
        }
        
        serverAPI = AgoraPopupQuizServerAPI(host: keys.host,
                                            appId: keys.agoraAppId,
                                            token: keys.token,
                                            roomId: info.roomInfo.roomUuid,
                                            userId: info.localUserInfo.userUuid,
                                            logTube: self)
    }
    
    func updateRoomData() {
        guard let roomProperties = info.roomProperties,
              let data = roomProperties.toObj(AgoraPopupQuizRoomPropertiesData.self) else {
            return
        }
        
        roomData = data
        
        guard let state = data.toViewSelectorState() else {
            return
        }
        
        selectorState = state // .end
        initResultList()
        stopTimer()
    }
    
    func initOptionList() {
        guard let data = roomData else {
            return
        }
        
        optionList = data.toViewSelectorOptionList()
        contentView.optionCollectionView.reloadData()
    }
    
    func initResultList() {
        guard let data = roomData else {
            return
        }
        
        let font = AgoraPopupQuizResultCell.font
        resultList = data.toViewSelectorResultList(font: font,
                                                    fontHeight: contentView.resultTableView.rowHeight,
                                                    myAnswer: findMyAnswer())
        contentView.resultTableView.reloadData()
    }
        
    func findMyAnswer() -> [String] {
        var selectedItems = [String]()
        
        // first, get selected items from local memory
        for item in optionList where item.isSelected {
            selectedItems.append(item.title)
        }
        
        // second, get selected items from local user properties
        if selectedItems.count == 0,
           let popupQuizId = info.localUserProperties?["popupQuizId"] as? String,
           let items = info.localUserProperties?["selectedItems"] as? [String],
           let extra = roomData,
           popupQuizId == extra.popupQuizId {
            for item in items {
                selectedItems.append(item)
            }
        }
        
        return selectedItems
    }
    
    func initTime() {
        guard let data = roomData,
              let objectCreate = objectCreateTimestamp else {
            return
        }
        
        let start = data.receiveQuestionTime
        let diff = objectCreate - start
        let msTimestamp = (diff < 0) ? 0 : diff // millisecond
        currentTimestamp = Int64(TimeInterval(msTimestamp) / 1000) // second
        
        if selectorState != .finished {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func startTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: { [weak self] _ in
                                            guard let strongSelf = self else {
                                                return
                                            }
                                            
                                            strongSelf.currentTimestamp += 1
        })
        
        RunLoop.main.add(timer,
                         forMode: .common)
        timer.fire()
        self.timer = timer
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private extension AgoraPopupQuizWidget {
    func submitAnswer() {
        guard let api = serverAPI,
              let extra = roomData else {
            return
        }
        
        api.submitAnswer(findMyAnswer(),
                         selectorId: extra.popupQuizId) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.selectorState = .changing
        }
    }
}

extension AgoraPopupQuizWidget: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return optionList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let option = optionList[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withClass: AgoraPopupQuizOptionCell.self,
                                                      for: indexPath)
        cell.optionLabel.text = option.title
        cell.optionIsSelected = option.isSelected
        cell.isEnable = !(selectorState == .changing)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        var option = optionList[indexPath.item]
        option.isSelected.toggle()
        optionList[indexPath.item] = option
        collectionView.reloadItems(at: [indexPath])
    }
}

extension AgoraPopupQuizWidget: UITableViewDataSource {
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = resultList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AgoraPopupQuizResultCell.cellId,
                                                 for: indexPath) as! AgoraPopupQuizResultCell
        let labelHeight = tableView.rowHeight
        
        cell.titleLabel.text = result.title
        cell.resultLabel.text = result.result
        cell.titleLabel.frame = CGRect(x: 40,
                                       y: 0,
                                       width: result.titleSize.width,
                                       height: labelHeight)
        
        cell.resultLabel.frame = CGRect(x: cell.titleLabel.frame.maxX,
                                        y: 0,
                                        width: 100,
                                        height: labelHeight)
        
        if let color = result.resultColor {
            cell.resultLabel.textColor = color
        }
        
        return cell
    }
}

extension AgoraPopupQuizWidget: ArLogTube {
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
