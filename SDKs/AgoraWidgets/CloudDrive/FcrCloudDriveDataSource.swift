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
    
    func createPrivateFileList(with originalDataList: [FcrCloudDriveFile]) -> Bool {
        var fileList = [FcrCloudDriveFileUnionData]()
        
        var hasConvertingFile = false
        
        for data in originalDataList {
            var state = FcrCloudDriveFileStateType.selectable(convertUnsuccessfully: false)
            
            if let progress = data.taskProgress {
                
                if let _ = progress.errorCode {
                    state = .selectable(convertUnsuccessfully: true)
                } else if progress.convertedPercentage != 100 {
                    state = .converting(progress.convertedPercentage)
                    hasConvertingFile = true
                }
            }
            
            let viewData = FcrCloudDriveFileViewData(name: data.resourceName,
                                                     ext: data.ext,
                                                     state: state)
            
            let file = FcrCloudDriveFileUnionData(viewData: viewData,
                                                  originalData: data)
            
            fileList.append(file)
        }
        
        privateFileList = fileList
        
        return hasConvertingFile
    }
    
    func updatePrivateFileListToSelectableState() {
        var new = privateFileList
        
        for i in 0..<privateFileList.count {
            var item = privateFileList[i]
            
            guard !item.viewData.state.isConverting else {
                continue
            }
            
            let unsuccessfully = item.viewData.state.hasConvertUnsuccessfully
            
            item.viewData.state = .selectable(convertUnsuccessfully: unsuccessfully)
            
            new[i] = item
        }
        
        privateFileList = new
    }
    
    func updateItemOfPrivateFileList(selectedState index: Int) {
        var new = privateFileList
        
        for i in 0..<privateFileList.count {
            var item = privateFileList[i]
            
            guard !item.viewData.state.isConverting else {
                continue
            }
            
            let isSelected = (i == index)
            
            let unsuccessfully = item.viewData.state.hasConvertUnsuccessfully
            
            item.viewData.state = .isSelected(isSelected: isSelected,
                                              convertUnsuccessfully: unsuccessfully)
            
            new[i] = item
        }
        
        privateFileList = new
    }
    
    func removeItemOfFileList(type: FcrCloudDriveFileViewType,
                              index: Int) {
        switch type {
        case .uiPrivate:
            var list = privateFileList
            list.remove(at: index)
            self.privateFileList = list
        case .uiPublic:
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
