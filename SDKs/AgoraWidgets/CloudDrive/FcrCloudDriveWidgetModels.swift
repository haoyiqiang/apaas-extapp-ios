//
//  FcrCloudWidgetModels.swift
//  AgoraWidgets
//
//  Created by Cavan on 2023/2/9.
//

import Foundation

// MARK: - View data
enum FcrCloudDriveFileViewType {
    case uiPublic, uiPrivate
    
    var isPublic: Bool {
        switch self {
        case .uiPublic:  return true
        case .uiPrivate: return false
        }
    }
}

enum FcrCloudDriveFileStateType {
    case notSelectable, selectable(convertUnsuccessfully: Bool), isSelected(isSelected: Bool, convertUnsuccessfully: Bool), converting(Int)
    
    var isConverting: Bool {
        switch self {
        case .converting: return true
        default:          return false
        }
    }
    
    var hasConvertUnsuccessfully: Bool {
        switch self {
        case .isSelected(let _, let convertUnsuccessfully): return convertUnsuccessfully
        case .selectable(let convertUnsuccessfully):        return convertUnsuccessfully
        default:                                            return false
        }
    }
}

struct FcrCloudDriveFileViewData {
    let image: UIImage?
    let name: String
    var state: FcrCloudDriveFileStateType
    
    init(name: String,
         ext: String,
         state: FcrCloudDriveFileStateType) {
        func getImage(with ext: String) -> UIImage? {
            let config = UIConfig.cloudStorage.cell.image
            
            switch ext {
            case "pptx", "ppt", "pptm":
                return config.pptImage
            case "docx", "doc":
                return config.docImage
            case "xlsx", "xls", "csv":
                return config.excelImage
            case "pdf":
                return config.pdfImage
            case "jpeg", "jpg", "png", "bmp":
                return config.picImage
            case "mp3", "wav", "wma", "aac", "flac", "m4a", "oga", "opu":
                return config.audioImage
            case "mp4", "3gp", "mgp", "mpeg", "3g2", "avi", "flv", "wmv", "h264",
                "m4v", "mj2", "mov", "ogg", "ogv", "rm", "qt", "vob", "webm":
                return config.videoImage
            case "alf":
                return config.alfImage
            default:
                return config.unknownImage
            }
        }
        
        self.name = name
        self.image = getImage(with: ext)
        self.state = state
    }
}

// MARK: - Server object
struct FcrCloudDriveFileListServerObject: Convertable {
    // File list
    let list: [FcrCloudDriveFile]
    // File list count
    let total: Int
    // Current page number
    let pageNo: Int
    // Per page count
    let pageSize: Int
    // Total pages
    let pages: Int
}
