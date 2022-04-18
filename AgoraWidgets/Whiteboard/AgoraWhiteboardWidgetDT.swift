//
//  AgoraWhiteboardWidgetDT.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/8.
//

import AgoraWidget
import Foundation
import Whiteboard

protocol AGBoardWidgetDTDelegate: NSObjectProtocol {
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool,
                                             completion: ((Bool) -> Void)?)
        
    func onScenePathChanged(path: String)
    func onGrantedUsersChanged(grantedUsers: [String])
    func onPageIndexChanged(index: Int)
    func onPageCountChanged(count: Int)
    
    func onConfigComplete()
}


class AgoraWhiteboardWidgetDT {
    weak var delegate: AGBoardWidgetDTDelegate?
    private let scheme = "agoranetless"
    // from whiteboard
    var regionDomain = "convertcdn"
        
    var baseMemberState: WhiteMemberState = {
        var state = WhiteMemberState()
        state.currentApplianceName = WhiteApplianceNameKey.ApplianceClicker
        state.strokeWidth = NSNumber(2)
        state.strokeColor = UIColor(hex: 0x0073FF)?.getRGBAArr()
        state.textSize = NSNumber(36)
        return state
    }()
    
    var coursewareList: Array<AgoraBoardCoursewareInfo>?
    
    @available(iOS 11.0, *)
    lazy var schemeHandler: AgoraWhiteURLSchemeHandler? = {
        return AgoraWhiteURLSchemeHandler(scheme: scheme,
                                          directory: configExtra.coursewareDirectory)
    }()

    var scenePath = "" {
        didSet {
            if scenePath != oldValue {
                delegate?.onScenePathChanged(path: scenePath)
            }
        }
    }
    
    var page = AgoraBoardPageInfo(index: 0,
                                  count: 0) {
        didSet {
            if page.index != oldValue.index {
                delegate?.onPageIndexChanged(index: page.index)
            }
            if page.count != oldValue.count {
                delegate?.onPageCountChanged(count: page.count)
            }
        }
    }
    
    var globalState = AgoraWhiteboardGlobalState()
    
    var currentMemberState: WhiteMemberState?
    
    var reconnectTime: Int = 0
    
    var isJoining: Bool = false
    
    var isSettingWritable = false
    
    // from properties
    var localCameraConfigs = [String: AgoraWhiteBoardCameraConfig]()

    var localGranted: Bool = false {
        didSet {
            if !isSettingWritable {
                delegate?.onLocalGrantedChangedForBoardHandle(localGranted: localGranted,
                                                              completion: nil)
            }
        }
    }
    
    var grantedUsers = [String]() {
        didSet {
            delegate?.onGrantedUsersChanged(grantedUsers: grantedUsers)
        }
    }
    
    // config
    var propsExtra: AgoraWhiteboardPropExtra? {
        didSet {
            guard let props = propsExtra else {
                return
            }
            if props.boardAppId != "",
               props.boardRegion != "",
               props.boardId != "",
               props.boardToken != "" {
                delegate?.onConfigComplete()
            }
            
            setUpGrantedUsers()
        }
    }
    var configExtra: AgoraWhiteboardExtraInfo
    var localUserInfo: AgoraWidgetUserInfo
    
    init(extra: AgoraWhiteboardExtraInfo,
         localUserInfo: AgoraWidgetUserInfo) {
        self.configExtra = extra
        self.localUserInfo = localUserInfo
        
        if let coursewareJsonList = extra.coursewareList,
           let infoList = transformPublicResources(coursewareJsonList: coursewareJsonList) {
            coursewareList = infoList
        }
    }
    
    func setUpGrantedUsers() {
        grantedUsers = propsExtra?.grantedUsers?.map({return $0.key}) ?? [String]()
        
        if localUserInfo.userRole != "teacher",
           let grant = propsExtra?.grantedUsers,
           grant.contains {$0.key == localUserInfo.userUuid} {
               localGranted = true
           } else {
               localGranted = false
           }
    }
    
    func updateMemberState(state: AgoraBoardMemberState) {
        if let tool = state.activeApplianceType {
            currentMemberState?.currentApplianceName = tool.toNetless()
        }
        
        if let colors = state.strokeColor {
            var stateColors = [NSNumber]()
            colors.forEach { color in
                stateColors.append(NSNumber(value: color))
            }
            currentMemberState?.strokeColor = stateColors
        }
        
        if let strokeWidth = state.strokeWidth {
            currentMemberState?.strokeWidth = NSNumber(value: strokeWidth)
        }
        
        if let textSize = state.textSize {
            currentMemberState?.textSize = NSNumber(value: textSize)
        }
        
        if let shape = state.shapeType {
            currentMemberState?.shapeType = shape.toNetless()
        }
    }
    
    func getWKConfig() -> WKWebViewConfiguration {
        let blueColor = "#75C0FF"
        let whiteColor = "#fff"
        let testColor = "#CC00FF"
        
        // tab style
        let tabBGStyle = """
                         var style = document.createElement('style');
                         style.innerHTML = '.telebox-titlebar { background: \(blueColor); }';
                         document.head.appendChild(style);
                         """
        
        let tabTitleStyle = """
                            var style = document.createElement('style');
                            style.innerHTML = '.telebox-title { color: \(whiteColor); }';
                            document.head.appendChild(style);
                            """
        
        let footViewBGStyle = """
                              var style = document.createElement('style');
                              style.innerHTML = '.netless-app-docs-viewer-footer { background: \(blueColor); }';
                              document.head.appendChild(style);
                              """
        
        let footViewPageLabelStyle = """
                                     var style = document.createElement('style');
                                     style.innerHTML = '.netless-app-docs-viewer-page-number { color: \(whiteColor); }';
                                     document.head.appendChild(style);
                                     """
        
        let footViewPageButtonStyle = """
                                      var style = document.createElement('style');
                                      style.innerHTML = '.netless-window-manager-wrapper .telebox-title, .netless-window-manager-wrapper .netless-app-docs-viewer-footer { color: \(whiteColor); }';
                                      document.head.appendChild(style);
                                      """
        let boardStyles = [tabBGStyle,
                           tabTitleStyle,
                           footViewBGStyle,
                           footViewPageLabelStyle,
                           footViewPageButtonStyle]
        
        let wkConfig = WKWebViewConfiguration()
#if arch(arm64)
        wkConfig.setValue("TRUE", forKey: "allowUniversalAccessFromFileURLs")
#else
        wkConfig.setValue("\(1)", forKey: "allowUniversalAccessFromFileURLs")
#endif
        if #available(iOS 11.0, *),
           let handler = self.schemeHandler {
            wkConfig.setURLSchemeHandler(handler,
                                         forURLScheme: scheme)
        }
        
        let ucc = WKUserContentController()
        for boardStyle in boardStyles {
            let userScript = WKUserScript(source: boardStyle,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            ucc.addUserScript(userScript)
        }
        wkConfig.userContentController = ucc
        return wkConfig
    }
    
    func getWhiteSDKConfigToInit() -> WhiteSdkConfiguration? {
        guard let props = propsExtra else {
            return nil
        }
        let config = WhiteSdkConfiguration(app: props.boardAppId)
        config.enableIFramePlugin = false
        if #available(iOS 11.0, *) {
            let pptParams = WhitePptParams()
            pptParams.scheme = scheme
            config.pptParams = pptParams
        }
        config.fonts = configExtra.fonts
        config.userCursor = true
        config.region = WhiteRegionKey(rawValue: props.boardRegion)
        config.useMultiViews = configExtra.useMultiViews ?? true
        
        return config
    }
    
    func getWhiteRoomConfigToJoin(ratio: CGFloat) -> WhiteRoomConfig? {
        guard let props = propsExtra else {
            return nil
        }
        let config = WhiteRoomConfig(uuid: props.boardId,
                                     roomToken: props.boardToken,
                                     uid: localUserInfo.userUuid,
                                     userPayload: ["cursorName": localUserInfo.userName])
        config.isWritable = false
        config.disableNewPencil = false
        
        let windowParams = WhiteWindowParams()
        windowParams.chessboard = false
        windowParams.containerSizeRatio = NSNumber.init(value: Float(ratio))
        windowParams.collectorStyles = configExtra.collectorStyles
        
        config.windowParams = windowParams
        
        return config
    }
    
    func netlessLinkURL(regionDomain: String,
                        taskUuid: String) -> String {
        return "https://\(regionDomain).netless.link/dynamicConvert/\(taskUuid).zip"
    }
    
    func netlessPublicCourseware() -> String {
        return "https://convertcdn.netless.link/publicFiles.zip"
    }
}

private extension AgoraWhiteboardWidgetDT {
    /// 公共课件转换
    func transformPublicResources(coursewareJsonList: Array<String> ) -> Array<AgoraBoardCoursewareInfo>? {
        guard coursewareJsonList.count > 0 else {
            return nil
        }
        var publicCoursewares = [AgoraBoardPublicCourseware]()
        for json in coursewareJsonList {
            if let data = json.data(using: .utf8),
               let courseware = try? JSONDecoder().decode(AgoraBoardPublicCourseware.self,
                                                          from: data) {
                publicCoursewares.append(courseware)
            }
        }
        
        return publicCoursewares.toCoursewareList()
    }
}
