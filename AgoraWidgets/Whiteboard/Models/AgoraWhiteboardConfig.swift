//
//  AgoraWhiteboardConfig.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/6.
//

import Whiteboard
import Security

enum AgoraWhiteboardLogType {
    case info, warning, error
}

struct AgoraWhiteboardPropExtra: Decodable {
    var boardAppId: String
    var boardId: String
    var boardToken: String
    var boardRegion: String
    var follow: Int32? // 是否跟随
    var grantUsers: [String]?
}

struct AgoraWhiteboardExtraInfo : Convertable {
    var useMultiViews: Bool
    var coursewareDirectory: String
    var coursewareList: Array<String>?
    var autoFit: Bool
    var fonts: Dictionary<String,String>?
    var collectorStyles: Dictionary<String,String>
    
    static func fromExtraDic(_ dic: Any?) -> AgoraWhiteboardExtraInfo {
        var extra = AgoraWhiteboardExtraInfo.defaultValue()
        
        if let extraDic = dic as? [String: Any] {
            if let useMultiViews = extraDic["useMultiViews"] as? Bool {
                extra.useMultiViews = useMultiViews
            }
            if let coursewareDirectory = extraDic["coursewareDirectory"] as? String {
                extra.coursewareDirectory = coursewareDirectory
            }
            if let autoFit = extraDic["autoFit"] as? Bool {
                extra.autoFit = autoFit
            }
            if let fonts = extraDic["fonts"] as? Dictionary<String,String> {
                extra.fonts = fonts
            }
            if let list = extraDic["coursewareList"] as? Array<String> {
                extra.coursewareList = list
            }
            
            if let collectorStyles = extraDic["collectorStyles"] as? Dictionary<String,String> {
                extra.collectorStyles = collectorStyles
            }
        }
        return extra
    }
    
    static func defaultValue() -> AgoraWhiteboardExtraInfo {
        let defaultCoursewareDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                       .userDomainMask,
                                                                       true)[0].appending("AgoraDownload")
        let length = UIDevice.current.isPad ? 34 : 32
        let left = UIDevice.current.isPad ? 15 : 12
        let bottom = UIDevice.current.isPad ? 20 : 15
        let defaultCollectorStyles = ["position":"fixed",
                                      "left":"\(left)px",
                                      "bottom":"\(bottom)px",
                                      "width":"\(length)px",
                                      "height":"\(length)px"]
        return AgoraWhiteboardExtraInfo(useMultiViews: true,
                                        coursewareDirectory: defaultCoursewareDir,
                                        autoFit: false,
                                        fonts: nil,
                                        collectorStyles: defaultCollectorStyles)
    }
}

@objcMembers class AgoraWhiteBoardTask: NSObject {
    var resourceUuid: String = ""
    var taskUuid: String = ""
    var extra: String = ""
}

@objcMembers public class AgoraWhiteboardGlobalState: WhiteGlobalState {
    var materialList: [AgoraWhiteBoardTask]?
    var currentSceneIndex: Int = 0
    var grantUsers = Array<String>()
    var teacherFirstLogin: Bool = false
}

@objc class AgoraWhiteBoardCameraConfig : NSObject {
    /** 白板视角中心 X 坐标，该坐标为中心在白板内部坐标系 X 轴中的坐标 */
    var centerX: CGFloat = 0
    /** 白板视角中心 Y 坐标，该坐标为中心在白板内部坐标系 Y 轴中的坐标 */
    var centerY: CGFloat = 0
    /** 缩放比例，白板视觉中心与白板的投影距离 */
    var scale: CGFloat = 1
}
