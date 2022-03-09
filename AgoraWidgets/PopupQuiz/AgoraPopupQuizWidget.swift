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

@objcMembers public class AgoraPopupQuizWidget: AgoraBaseWidget {
    private var logger: AgoraLogger {
        let folderPath = GetWidgetLogFolder()
        
        let logger = AgoraLogger(folderPath: folderPath,
                                 filePrefix: "AnswerSelector",
                                 maximumNumberOfFiles: 5)
        logger.setPrintOnConsoleType(.all)
        return logger
    }
    
    private var serverAPI: AgoraPopupQuizServerAPI?
    private var timer: Timer?
    
    // View
    private let contentView = AgoraPopupQuizView() // for mask shadow
    private var lastViewSize = CGSize.zero
    
    // Data
    private var optionList = [AgoraPopupQuizOption]() {
        didSet {
            if let _ = optionList.first(where: {$0.isSelected}) {
                selectorState = .post
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
    
    private var baseInfo: AgoraAppBaseInfo?
    
    private var extraData: AgoraPopupQuizExtraData?
    
    private var objectCreateTimestamp: Int64?
    private var currentTimestamp: Int64 = 0 { // second
        didSet {
            let timeString = currentTimestamp.formatStringHMS
            contentView.topView.update(timeString: timeString)
        }
    }
    
    public override func onWidgetDidLoad() {
        super.onWidgetDidLoad()
        view.delegate = self
        
        createViews()
        createConstrains()
        initExtraData()
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
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String]) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths)
        updateExtraData()
    }
    
    @objc func doButtonPressed(_ sender: UIButton) {
        switch selectorState {
        case .post:
            submitAnswer()
        case .change:
            selectorState = .post
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
    
    func createConstrains() {
        contentView.mas_makeConstraints { (make) in
            make?.top.left()?.right()?.bottom()?.equalTo()(0)
        }
    }
}

// MAKR: - Data
private extension AgoraPopupQuizWidget {
    func initExtraData() {
        guard let roomProperties = info.roomProperties,
              let extra = roomProperties.toObj(AgoraPopupQuizExtraData.self) else {
            return
        }
        
        extraData = extra
        
        if let state = extra.toViewSelectorState() {
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
              let extra = extraData else {
            return
        }
        
        serverAPI = AgoraPopupQuizServerAPI(host: keys.host,
                                                 appId: keys.agoraAppId,
                                                 token: keys.token,
                                                 roomId: info.roomInfo.roomUuid,
                                                 userId: info.localUserInfo.userUuid,
                                                 logTube: self)
    }
    
    func updateExtraData() {
        guard let roomProperties = info.roomProperties,
              let extra = roomProperties.toObj(AgoraPopupQuizExtraData.self) else {
            return
        }
        
        extraData = extra
        
        guard let state = extra.toViewSelectorState() else {
            return
        }
        
        selectorState = state // .end
        initResultList()
    }
    
    func initOptionList() {
        guard let extra = extraData else {
            return
        }
        
        optionList = extra.toViewSelectorOptionList()
        contentView.optionCollectionView.reloadData()
    }
    
    func initResultList() {
        guard let extra = extraData else {
            return
        }
        
        let font = AgoraPopupQuizResultCell.font
        resultList = extra.toViewSelectorResultList(font: font,
                                                    fontHeight: contentView.resultTableView.rowHeight,
                                                    myAnswer: findMyAnswer())
        contentView.resultTableView.reloadData()
    }
        
    func findMyAnswer() -> [String] {
        var selectedItems = [String]()
        
        guard let extra = extraData else {
            return selectedItems
        }
        
        // first, get selected items from local memory
        for item in optionList where item.isSelected {
            selectedItems.append(item.title)
        }
        
        // second, get selected items from local user properties
        if selectedItems.count == 0,
           let selectedId = info.localUserProperties?["selectorId"] as? String,
           let items = info.localUserProperties?["selectedItems"] as? [String],
           selectedId == extra.popupQuizId {
            for item in items {
                selectedItems.append(item)
            }
        }
        
        return selectedItems
    }
    
    func initTime() {
        guard let extra = extraData,
              let objectCreate = objectCreateTimestamp else {
            return
        }
        
        let start = extra.receiveQuestionTime
        let diff = objectCreate - start
        let msTimestamp = (diff < 0) ? 0 : diff // millisecond
        currentTimestamp = Int64(TimeInterval(msTimestamp) / 1000) // second
        
        if selectorState != .end {
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
        guard let api = serverAPI, let extra = extraData else {
            return
        }
        
        api.submitAnswer(findMyAnswer(),
                         selectorId: extra.popupQuizId) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.selectorState = .change
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
        cell.isEnable = !(selectorState == .change)
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
        let labelHeight = AgoraPopupQuizResultCell.labelHeight
        
        cell.titleLabel.text = result.title
        cell.resultLabel.text = result.result
        cell.titleLabel.frame = CGRect(x: 55,
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

extension AgoraPopupQuizWidget: AgoraUIContainerDelegate {
    public func containerLayoutSubviews() {
        guard lastViewSize != view.bounds.size else {
            return
        }
        lastViewSize = view.bounds.size
        contentView.collectionViewLayout(superViewSize: lastViewSize)
    }
}

extension AgoraPopupQuizWidget: ArLogTube {
    public func log(info: String,
                    extra: String?) {
        var log = info
        
        if let ext = extra {
            log += ext
        }
        
        logger.log(log,
                   type: .info)
    }
    
    public func log(warning: String,
                    extra: String?) {
        var log = warning
        
        if let ext = extra {
            log += ext
        }
        
        logger.log(log,
                   type: .warning)
    }
    
    public func log(error: ArError,
                    extra: String?) {
        var log = error.localizedDescription
        
        if let ext = extra {
            log += ext
        }
        
        logger.log(log,
                   type: .error)
    }
}
