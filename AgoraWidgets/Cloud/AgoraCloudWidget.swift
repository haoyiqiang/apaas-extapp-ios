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

@objcMembers public class AgoraCloudWidget: AgoraBaseWidget {
    /**Data*/
    private var vm: AgoraCloudVM
    private var serverApi: AgoraCloudServerAPI?
    private let logger: AgoraLogger
    /**View*/
    private lazy var cloudView:AgoraCloudView = {
        let view = AgoraCloudView(frame: .zero)
        let list = self.vm.getCellCoursewares(type: self.vm.selectedType)
        view.listView.update(infos: list)
        return view
    }()
    
    public override init(widgetInfo: AgoraWidgetInfo) {
        self.vm = AgoraCloudVM(extra: widgetInfo.extraInfo)
        self.logger = AgoraLogger(folderPath: GetWidgetLogFolder(),
                                  filePrefix: widgetInfo.widgetId,
                                  maximumNumberOfFiles: 5)
        // MARK: 在此修改日志是否打印在控制台,默认为不打印
        self.logger.setPrintOnConsoleType(.all)
        
        super.init(widgetInfo: widgetInfo)
        initViews()
    }
    
    public override func onMessageReceived(_ message: String) {
        log(.info,
            log: "onMessageReceived:\(message)")
        
        if let baseInfo = message.toAppBaseInfo() {
            serverApi = AgoraCloudServerAPI(baseInfo: baseInfo,
                                            uid: info.localUserInfo.userUuid)
        }
    }
}

extension AgoraCloudWidget: AgoraCloudTopViewDelegate, AgoraCloudListViewDelegate {
    // MARK: - AgoraCloudTopViewDelegate
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudCoursewareType) {
        vm.selectedType = type
        let cellInfos = self.vm.getCellCoursewares(type: type)
        self.cloudView.listView.update(infos: cellInfos)
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
            let cellInfos = self.vm.getCellCoursewares(type: .privateResource)
            self.cloudView.listView.update(infos: cellInfos)
        } fail: {[weak self] error in
            self?.log(.error,
                      log: error.localizedDescription)
        }
    }
    
    func agoraCloudTopViewDidSearch(type: AgoraCloudUIFileType,
                                    keyStr: String) {
        let dataType: AgoraCloudCoursewareType = (type == .uiPublic) ? .publicResource : .privateResource

        guard keyStr != "" else {
            let list = vm.getCellCoursewares(type: dataType)
            cloudView.listView.update(infos: list)
            return
        }
        switch dataType {
        case .publicResource:
            let newList = vm.publicFiles.filter{ $0.resourceName.contains(keyStr) }
            cloudView.listView.update(infos: newList.toCellInfos())
        case .privateResource:
            let newList = vm.privateFiles.filter{ $0.resourceName.contains(keyStr) }
            cloudView.listView.update(infos: newList.toCellInfos())
        }
    }
    
    // MARK: - AgoraCloudListViewDelegate
    func agoraCloudListViewDidSelectedIndex(index: Int) {
        guard let coursewareInfo = vm.getSelectedInfo(index: index) else {
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
        cloudView.listView.listDelegate = self
        
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
    
    func log(_ type: AgoraLogType,
             log: String) {
        switch type {
        case .info:
            logger.log("[Cloud widget] \(log)",
                       type: .info)
        case .warning:
            logger.log("[Cloud widget] \(log)",
                       type: .warning)
        case .error:
            logger.log("[Cloud widget] \(log)",
                       type: .error)
        default:
            logger.log("[Cloud widget] \(log)",
                       type: .info)
        }
    }
}
