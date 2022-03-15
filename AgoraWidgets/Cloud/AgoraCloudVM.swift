//
//  AgoraCloudVM.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/23.
//

import AgoraWidget

class AgoraCloudVM: NSObject {
    var selectedType: AgoraCloudCoursewareType = .publicResource
    
    private(set) var publicFiles = [AgoraCloudCourseware]()
    private(set) var privateFiles = [AgoraCloudCourseware]()
    
    init(extra: Any?) {
        super.init()
        // public
        transformPublicResources(extraInfo: extra)
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
                                         scenes: config.scenes,
                                         convert: config.convert)
    }
    
    func getCellCoursewares(type: AgoraCloudCoursewareType) -> [AgoraCloudCellInfo] {
        switch type {
        case .publicResource:
            return publicFiles.toCellInfos()
        case .privateResource:
            return privateFiles.toCellInfos()
        }
    }
}

// MARK: - private
private extension AgoraCloudVM {
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
