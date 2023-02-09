//
//  AgoraCloudVM.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/23.
//

import AgoraWidget

class AgoraCloudVM: NSObject {
    var selectedType: AgoraCloudCoursewareType = .publicResource {
        didSet {
            handleCurrentCoursewares()
        }
    }
    
    var currentFilterStr: String = "" {
        didSet {
            handleCurrentCoursewares()
        }
    }
    
    
    
    private(set) var originPublicFileList = [FcrCloudFileListServerObject.File]()
    private(set) var originPrivateFileList = [FcrCloudFileListServerObject.File]()
    
    private(set)
    
    private(set) var currentFiles = [AgoraCloudCellInfo]()
    private(set) var publicFiles = [AgoraCloudCourseware]()
    private(set) var privateFiles = [AgoraCloudCourseware]()
    
    init(extra: Any?) {
        super.init()
        // public
        transformPublicResources(extraInfo: extra)
        handleCurrentCoursewares()
    }
    
    func updatePrivate(_ files: [AgoraCloudCourseware]?) {
        privateFiles = files ?? [AgoraCloudCourseware]()
        handleCurrentCoursewares()
    }
    
    func getSelectedInfo(index: Int) -> AgoraCloudBoardCoursewareInfo? {
        let dataList: [AgoraCloudCourseware] = (selectedType == .publicResource) ? publicFiles : privateFiles
        
        guard dataList.count > index else {
            return nil
        }
        let config = dataList[index]
        return AgoraCloudBoardCoursewareInfo(resourceUuid: config.resourceUuid,
                                             resourceName: config.resourceName,
                                             resourceUrl: config.resourceURL,
                                             taskUuid: config.taskUuid,
                                             prefix: config.`prefix`,
                                             ext: config.ext,
                                             scenes: config.scenes?.toCloudBoard,
                                             convert: config.convert)
    }
}

// MARK: - private
private extension AgoraCloudVM {
    func handleCurrentCoursewares() {
        var courseFiles = [AgoraCloudCourseware]()
        if currentFilterStr == "" {
            courseFiles = (selectedType == .publicResource ? publicFiles : privateFiles)
        } else {
            switch selectedType {
            case .publicResource:
                courseFiles = publicFiles.filter{ $0.resourceName.contains(currentFilterStr) }
            case .privateResource:
                courseFiles = privateFiles.filter{ $0.resourceName.contains(currentFilterStr) }
            }
        }
        currentFiles = courseFiles.toCellInfos()
    }
    
    func transformPublicResources(extraInfo: Any?) {
        guard let extraInfo = ValueTransform(value: extraInfo,
                                             result: [String: Any].self),
              let publicJsonArray = ValueTransform(value: extraInfo["publicCoursewares"],
                                                   result: [String].self),
              publicJsonArray.count > 0
        else {
            return
        }
        
        var fileList = [FcrCloudFileListServerObject.File]()
        
        for jsonSring in publicJsonArray {
            guard let json = jsonSring.toDictionary(),
                  let file = try? FcrCloudFileListServerObject.File.decode(json)
            else {
                continue
            }
            
            fileList.append(file)
        }
        
        originPublicFileList = fileList
    }
}
