//
//  FcrBoardWidgetDT.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/6/14.
//

import Foundation

protocol FcrBoardWidgetDTDelegate: NSObjectProtocol {
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool)
//
//    func onScenePathChanged(path: String)
    func onGrantedUsersChanged(grantedUsers: [String])
    func onPageIndexChanged(index: Int)
    func onPageCountChanged(count: Int)
    
    func onConfigComplete()
}

class FcrBoardWidgetDT {
    weak var delegate: FcrBoardWidgetDTDelegate?
    var localUserInfo: AgoraWidgetUserInfo
    var roomName: String
    
    private let dateFormatter: DateFormatter
    var snapshotName: String {
        get {
            return dateFormatter.string(from: Date())
        }
    }
    
    var currentSnapshotFolder: String = ""
    var snapshotFolder: String {
        get {
            let folderName = "\(roomName)_\(snapshotName)"
            let folder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                             .userDomainMask,
                                                             true)[0].appendingPathComponent(folderName)
            currentSnapshotFolder = folder
            return folder
        }
    }
    
    var configExtra: FcrBooardConfigOfExtra? {
        didSet {
            guard let config = configExtra,
                  config.boardAppId != "",
                  config.boardRegion != "",
                  config.boardId != "",
                  config.boardToken != "" else {
                return
            }
            delegate?.onConfigComplete()
        }
    }
    
    var grantedUsers = [String: Bool]() {
        didSet {
            guard grantedUsers != oldValue else {
                return
            }
            delegate?.onGrantedUsersChanged(grantedUsers: Array(grantedUsers.keys))
            
            if !isLocalTeacher() {
                hasOperationPrivilege = grantedUsers.keys.contains(localUserInfo.userUuid)
            }
        }
    }
    
    // 教师角色加入房间成功时设置，学生角色监听grantedUsers变化设置
    var hasOperationPrivilege: Bool = false {
        didSet {
            guard hasOperationPrivilege != oldValue else {
                return
            }
            delegate?.onLocalGrantedChangedForBoardHandle(localGranted: hasOperationPrivilege)
        }
    }
    
    var page: (index: Int, count: Int) = (index: 0, count: 0) {
        didSet {
            if page.index != oldValue.index {
                delegate?.onPageIndexChanged(index: page.index)
            }
            if page.count != oldValue.count {
                delegate?.onPageCountChanged(count: page.count)
            }
        }
    }
    
    var imageCountToSave: Int = 0
    
    init(localUserInfo: AgoraWidgetUserInfo,
         roomName: String) {
        self.localUserInfo = localUserInfo
        self.roomName = roomName
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
    }
}


extension FcrBoardWidgetDT {
    func isLocalTeacher() -> Bool {
        return (localUserInfo.userRole == "teacher")
    }
}
