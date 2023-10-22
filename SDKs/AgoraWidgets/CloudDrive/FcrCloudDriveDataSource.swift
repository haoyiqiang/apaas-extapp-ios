//
//  FcrCloudDriveDataSource.swift
//  AgoraWidgets
//
//  Created by Cavan on 2023/02/10.
//

import AgoraWidget

struct FcrCloudDriveFileUnionData {
    var viewData: FcrCloudDriveFileViewData
    var originalData: FcrCloudDriveFile
}

class FcrCloudDriveDataSource: NSObject {
    private(set) var publicFileList = [FcrCloudDriveFileUnionData]()
    private(set) var privateFileList = [FcrCloudDriveFileUnionData]()
    private(set) var filteredFileList = [FcrCloudDriveFileUnionData]()
    
    func createPublicFileList(with jsonStringList: [String]) {
        var fileList = [FcrCloudDriveFileUnionData]()
        
        for jsonSring in jsonStringList {
            guard let json = jsonSring.toDictionary(),
                  let originalData = try? FcrCloudDriveFile.decode(json)
            else {
                continue
            }
            
            let viewData = FcrCloudDriveFileViewData(name: originalData.resourceName,
                                                     ext: originalData.ext,
                                                     state: .notSelectable)
            
            let file = FcrCloudDriveFileUnionData(viewData: viewData,
                                                  originalData: originalData)
            
            fileList.append(file)
        }
        
        publicFileList = fileList
    }
    
    func createPrivateFileList(with originalDataList: [FcrCloudDriveFile]) {
        var fileList = [FcrCloudDriveFileUnionData]()
        
        for data in originalDataList {
            let viewData = FcrCloudDriveFileViewData(name: data.resourceName,
                                                     ext: data.ext,
                                                     state: .selectable)
            
            let file = FcrCloudDriveFileUnionData(viewData: viewData,
                                                  originalData: data)
            
            fileList.append(file)
        }
        
        privateFileList = fileList
    }
    
    func remove(type: FcrCloudDriveFileViewType,
                index: Int) {
        switch type {
        case .uiPublic:
            var list = privateFileList
            list.remove(at: index)
            self.privateFileList = list
        case .uiPrivate:
            var list = publicFileList
            list.remove(at: index)
            self.publicFileList = list
        }
    }
    
    func filterFileList(with type: FcrCloudDriveFileViewType,
                        keyWords: String? = nil) {
        var filteredFileList: [FcrCloudDriveFileUnionData]
        
        switch type {
        case .uiPublic:
            filteredFileList = publicFileList
        case .uiPrivate:
            filteredFileList = privateFileList
        }
        
        if let `keyWords` = keyWords,
            keyWords.count > 0 {
            filteredFileList = filteredFileList.filter({$0.viewData.name.contains(keyWords)})
        }
        
        self.filteredFileList = filteredFileList
    }
}
