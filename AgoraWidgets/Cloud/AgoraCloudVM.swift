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
    }
    
    func getSelectedInfo(index: Int) -> AgoraCloudWhiteScenesInfo? {
        let dataList: [AgoraCloudCourseware] = (selectedType == .publicResource) ? publicFiles : privateFiles
        
        guard dataList.count > index else {
            return nil
        }
        let config = dataList[index]
        return AgoraCloudWhiteScenesInfo(resourceName: config.resourceName,
                                         resourceUuid: config.resourceUuid,
                                         resourceUrl: config.resourceURL,
                                         scenes: config.scenes,
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
    /// 公共课件转换
    func transformPublicResources(extraInfo: Any?) {
        guard let extraInfo = extraInfo as? Dictionary<String,Any>,
              let publicJsonArr = extraInfo["publicCoursewares"] as? Array<String>,
              publicJsonArr.count > 0 else {
                  return
              }
        var publicCoursewares = [AgoraCloudPublicCourseware]()
        for json in publicJsonArr {
            if let data = json.data(using: .utf8),
            let courseware = try? JSONDecoder().decode(AgoraCloudPublicCourseware.self,
                                                        from: data) {
                publicCoursewares.append(courseware)
            }
        }

        self.publicFiles = publicCoursewares.toConfig()
    }
}
