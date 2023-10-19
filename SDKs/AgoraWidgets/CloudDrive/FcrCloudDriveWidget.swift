//
//  AgoraCloudWidget.swift
//  AFNetworking
//
//  Created by ZYP on 2021/10/20.
//

import MobileCoreServices
import AgoraWidget
import AgoraLog
import Masonry
import Photos
import Darwin

@objcMembers public class FcrCloudDriveWidget: AgoraNativeWidget,
                                               AgoraUIContentContainer {
    private let contentView = FcrCloudDriveView(frame: .zero)
    private var dataSource = FcrCloudDriveDataSource()
    private var serverAPI: FcrCloudDriveServerAPI?
    
    public override func onLoad() {
        super.onLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        createPublicDataSource()
        dataSource.filterFileList(with: .uiPublic)
        contentView.listView.reloadData()
    }
    
    public override func onMessageReceived(_ message: String) {
        guard let keys = message.toRequestKeys() else {
            return
        }
        
        serverAPI = FcrCloudDriveServerAPI(host: keys.host,
                                           appId: keys.agoraAppId,
                                           token: keys.token,
                                           roomId: info.roomInfo.roomUuid,
                                           userId: info.localUserInfo.userUuid,
                                           logTube: self.logger)
        
        createPrivateDataSource { [weak self] in
            guard let contentView = self?.contentView else {
                return
            }
            
            guard contentView.topView.selectedType == .uiPrivate else {
                return
            }
            
            contentView.listView.reloadData()
        }
    }
    
    public func initViews() {
        view.backgroundColor = .clear
        view.addSubview(contentView)
        
        contentView.topView.delegate = self
        contentView.listView.dataSource = self
        contentView.listView.delegate = self
        
        contentView.topView.updateFileCount(dataSource.filteredFileList.count)
        
        contentView.bottomView.uploadFileButton.addTarget(self,
                                                          action: #selector(onUploadFileButtonPressed),
                                                          for: .touchUpInside)
        
        contentView.bottomView.uploadImageButton.addTarget(self,
                                                           action: #selector(onUploadImageButtonPressed),
                                                           for: .touchUpInside)
    }
    
    public func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.cloudStorage
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
    }
}

// MARK: - Data
private extension FcrCloudDriveWidget {
    func createPublicDataSource() {
        guard let extraInfo = ValueTransform(value: info.extraInfo,
                                             result: [String: Any].self),
              let jsonArray = ValueTransform(value: extraInfo["publicCoursewares"],
                                             result: [String].self)
        else {
            return
        }
        
        dataSource.createPublicFileList(with: jsonArray)
    }
    
    func createPrivateDataSource(success: (() -> ())? = nil,
                                 failure: ((Error) -> ())? = nil) {
        fetchPrivateFileList { [weak self] object in
            guard let `self` = self else {
                return
            }
            
            self.dataSource.createPrivateFileList(with: object.list)
            success?()
        } failure: { error in
            failure?(error)
        }
    }
    
    func fetchPrivateFileList(resourceName: String? = nil,
                              success: ((FcrCloudDriveFileListServerObject) -> ())?,
                              failure: ((Error) -> ())?) {
        guard let `serverApi` = serverAPI else {
            return
        }
        
        serverApi.requestResourceInUser(pageNo: 1,
                                        pageSize: 20,
                                        resourceName: resourceName) { [weak self] (object) in
            success?(object)
        } failure: { [weak self](error) in
            failure?(error)
        }
    }
}

// MARK: - FcrCloudDriveTopViewDelegate
extension FcrCloudDriveWidget: FcrCloudDriveTopViewDelegate {
    func onTypeButtonPressed(type: FcrCloudDriveFileViewType) {
        dataSource.filterFileList(with: type,
                                  keyWords: contentView.topView.searchBar.text)
        
        contentView.topView.updateFileCount(dataSource.filteredFileList.count)
        
        contentView.listView.reloadData()
        
        contentView.bottomView.isHidden = (type == .uiPublic)
    }
    
    func onCloseButtonPressed() {
        sendCloseMessage()
    }
    
    func onRefreshButtonPressed() {
        guard contentView.topView.selectedType == .uiPrivate else {
            return
        }
        
        createPrivateDataSource { [weak self] in
            self?.contentView.listView.reloadData()
        }
    }
    
    func onSearched(content: String) {
        dataSource.filterFileList(with: contentView.topView.selectedType,
                                  keyWords: content)
        
        contentView.listView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FcrCloudDriveWidget: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return dataSource.filteredFileList.count
    }
    
    public func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FcrCloudDriveCell.cellId,
                                                 for: indexPath) as! FcrCloudDriveCell
        
        let data = dataSource.filteredFileList[indexPath.row].viewData
        cell.iconImageView.image = data.image
        cell.nameLabel.text = data.name
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        let data = dataSource.filteredFileList[indexPath.row].originalData
        
        sendSelectedFileMessage(data: data)
    }
}

private extension FcrCloudDriveWidget {
    @objc func onUploadFileButtonPressed() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"],
                                                            in: .import)
        documentPicker.delegate = self
        
        let vc = UIViewController.agora_top_view_controller()
        
        vc.present(documentPicker,
                   animated: true)
    }
    
    @objc func onUploadImageButtonPressed() {
        let vc = UIViewController.agora_top_view_controller()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        
        vc.present(imagePicker,
                   animated: true)
    }
}

extension FcrCloudDriveWidget: UIDocumentPickerDelegate,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentsAt urls: [URL]) {
        
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - private
private extension FcrCloudDriveWidget {
    func sendSelectedFileMessage(data: FcrCloudDriveFile) {
        guard let dictionary = data.toDictionary() else {
            return
        }
        
        var json = ["selectedFile": dictionary]
        
        guard let jsonString = json.jsonString() else {
            return
        }
        
        sendMessage(jsonString)
    }
    
    func sendCloseMessage() {
        var json = ["close": true]
        
        guard let jsonString = json.jsonString() else {
            return
        }
        
        sendMessage(jsonString)
    }
}
