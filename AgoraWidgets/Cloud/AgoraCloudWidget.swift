//
//  AgoraCloudWidget.swift
//  AFNetworking
//
//  Created by ZYP on 2021/10/20.
//

import AgoraWidget
import AgoraLog
import Masonry
import Darwin

@objcMembers public class AgoraCloudWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    /**Data*/
    private var vm: AgoraCloudVM
    private var serverApi: AgoraCloudServerAPI?
    var logger: AgoraWidgetLogger
    /**View*/
    private let cloudView = AgoraCloudView(frame: .zero)
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        self.vm = AgoraCloudVM(extra: widgetInfo.extraInfo)
        
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
        initViews()
    }
    
    public override func onMessageReceived(_ message: String) {
        log(content: "onMessageReceived:\(message)",
            type: .info)
        
        if let baseInfo = message.toAppBaseInfo() {
            serverApi = AgoraCloudServerAPI(baseInfo: baseInfo,
                                            uid: info.localUserInfo.userUuid)
        }
    }
}

extension AgoraCloudWidget: AgoraCloudTopViewDelegate {
    // MARK: - AgoraCloudTopViewDelegate
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudUIFileType) {
        vm.selectedType = type.dataType
        cloudView.topView.update(selectedType: type)
        cloudView.listView.reloadData()
    }
    
    func agoraCloudTopViewDidTapCloseButton() {
        sendMessage(signal: .CloseCloud)
    }
    
    func agoraCloudTopViewDidTapRefreshButton() {
        // public为extraInfo传入，无需更新
        guard vm.selectedType == .privateResource else {
            return
        }
        fetchPrivate {[weak self] list in
            guard let `self` = self else {
                return
            }

            self.cloudView.listView.reloadData()
        } fail: {[weak self] error in
            self?.log(content: error.localizedDescription,
                      type: .error)
        }
    }
    
    func agoraCloudTopViewDidSearch(keyStr: String) {
        vm.currentFilterStr = keyStr
        cloudView.listView.reloadData()
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension AgoraCloudWidget: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return vm.currentFiles.count
    }
    
    public func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cloudView.listView.cellId,
                                             for: indexPath) as! AgoraCloudCell
        let info = vm.currentFiles[indexPath.row]
        cell.iconImageView.image = info.image
        cell.nameLabel.text = info.name
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        guard let coursewareInfo = vm.getSelectedInfo(index: indexPath.row) else {
            return
        }
        sendMessage(signal: .OpenCoursewares(coursewareInfo))
    }
}

// MARK: - private
private extension AgoraCloudWidget {
    func sendMessage(signal: AgoraCloudInteractionSignal) {
        guard let text = signal.toMessageString() else {
            return
        }
        sendMessage(text)
    }
    func initViews() {
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        view.addSubview(cloudView)
        
        cloudView.topView.delegate = self
        cloudView.listView.dataSource = self
        cloudView.listView.delegate = self
        cloudView.listView.reloadData()
        cloudView.topView.update(selectedType: vm.selectedType.uiType)
        
        cloudView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
    }

    /// 获取个人数据
    func fetchPrivate(success: (([AgoraCloudCourseware]) -> ())?,
                      fail: ((Error) -> ())?) {
        guard let `serverApi` = serverApi else {
            return
        }
        serverApi.requestResourceInUser(pageNo: 0,
                                        pageSize: 300) { [weak self] (resp) in
            guard let `self` = self else {
                return
            }
            var temp = self.vm.privateFiles
            let list = resp.data.list.map({ AgoraCloudCourseware(fileItem: $0) })
            for item in list {
                if !temp.contains(where: {$0.resourceUuid == item.resourceUuid}) {
                    temp.append(item)
                }
            }
            self.vm.updatePrivate(temp)
            success?(temp)
        } fail: { [weak self](error) in
            fail?(error)
        }
    }
}
