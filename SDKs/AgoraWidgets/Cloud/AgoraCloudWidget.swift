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

@objcMembers public class AgoraCloudWidget: AgoraNativeWidget {
    /**Data*/
    private var vm: AgoraCloudVM
    private var serverApi: AgoraCloudServerAPI?
    
    /**View*/
    private let cloudView = AgoraCloudView(frame: .zero)
    
    override init(widgetInfo: AgoraWidgetInfo) {
        self.vm = AgoraCloudVM(extra: widgetInfo.extraInfo)
        super.init(widgetInfo: widgetInfo)
    }
    
    public override func onLoad() {
        super.onLoad()
        initViews()
        updateViewProperties()
    }
    
    public override func onMessageReceived(_ message: String) {
        log(content: "onMessageReceived:\(message)",
            type: .info)
        
        if let keys = message.toRequestKeys() {
            serverApi = AgoraCloudServerAPI(host: keys.host,
                                            appId: keys.agoraAppId,
                                            token: keys.token,
                                            roomId: info.roomInfo.roomUuid,
                                            userId: info.localUserInfo.userUuid,
                                            logTube: self.logger)
            // init private data
            fetchPrivate(success: nil,
                         failure: nil)
        }
    }
}

extension AgoraCloudWidget: AgoraCloudTopViewDelegate {
    // MARK: - AgoraCloudTopViewDelegate
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudUIFileType) {
        vm.selectedType = type.dataType
        cloudView.topView.update(selectedType: type)
        cloudView.topView.set(fileNum: vm.currentFiles.count)
        cloudView.listView.reloadData()
    }
    
    func agoraCloudTopViewDidTapCloseButton() {
        sendMessage(signal: .closeCloud)
    }
    
    func agoraCloudTopViewDidTapRefreshButton() {
        // public为extraInfo传入，无需更新
        guard vm.selectedType == .privateResource else {
            return
        }
        
        fetchPrivate { [weak self] list in
            guard let `self` = self else {
                return
            }

            self.cloudView.listView.reloadData()
        } failure: { [weak self] error in
            self?.log(content: error.localizedDescription,
                      type: .error)
        }
    }
    
    func agoraCloudTopViewDidSearch(keyStr: String) {
        guard vm.selectedType == .privateResource else {
            return
        }
        
        fetchPrivate(resourceName: keyStr) { [weak self] list in
            guard let `self` = self else {
                return
            }
            self.vm.currentFilterStr = keyStr
            self.cloudView.listView.reloadData()
        } failure: { [weak self] error in
            self?.log(content: error.localizedDescription,
                      type: .error)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: AgoraCloudCell.cellId,
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
        
        sendMessage(signal: .openCourseware(coursewareInfo))
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
        view.addSubview(cloudView)
        
        cloudView.topView.delegate = self
        cloudView.listView.dataSource = self
        cloudView.listView.delegate = self
        cloudView.listView.reloadData()
        cloudView.topView.update(selectedType: vm.selectedType.uiType)
        cloudView.topView.set(fileNum: vm.currentFiles.count)
        
        cloudView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.cloudStorage
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
    }

    /// 获取个人数据
    func fetchPrivate(resourceName: String? = nil,
                      success: (([AgoraCloudCourseware]) -> ())?,
                      failure: ((Error) -> ())?) {
        guard let `serverApi` = serverApi else {
            return
        }
        
        serverApi.requestResourceInUser(pageNo: 1,
                                        pageSize: 10,
                                        resourceName: resourceName) { [weak self] (resp) in
            guard let `self` = self else {
                return
            }
            var temp = self.vm.privateFiles
            let list = resp.list.map({ $0.toCloud })
            for item in list {
                if !temp.contains(where: {$0.resourceUuid == item.resourceUuid}) {
                    temp.append(item)
                }
            }
            self.vm.updatePrivate(temp)
            success?(temp)
        } failure: { [weak self](error) in
            failure?(error)
        }
    }
}
