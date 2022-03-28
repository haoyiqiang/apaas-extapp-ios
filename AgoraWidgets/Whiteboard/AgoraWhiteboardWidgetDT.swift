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
    func onGrantUsersChanged(grantUsers: [String])
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
    
    var globalState = AgoraWhiteboardGlobalState() {
        didSet {
            // 授权相关
            if localUserInfo.userRole != "teacher" {
                // 若为学生，涉及localGranted
                if globalState.grantUsers.contains(localUserInfo.userUuid),
                   !localGranted {
                    localGranted = true
                    delegate?.onLocalGrantedChangedForBoardHandle(localGranted: true,
                                                                  completion: nil)
                } else if globalState.teacherFirstLogin {
                    localGranted = false
                    delegate?.onLocalGrantedChangedForBoardHandle(localGranted: false,
                                                                  completion: nil)
                }
            }
            delegate?.onGrantUsersChanged(grantUsers: globalState.grantUsers)
        }
    }
    
    var currentMemberState: WhiteMemberState?
    
    var reconnectTime: Int = 0
    
    // from properties
    var localCameraConfigs = [String: AgoraWhiteBoardCameraConfig]()

    var localGranted: Bool = false
    
    // config
    var propsExtra: AgoraWhiteboardPropExtra? {
        didSet {
            if let props = propsExtra {
                if props.boardAppId != "",
                   props.boardRegion != "",
                   props.boardId != "",
                   props.boardToken != "" {
                    delegate?.onConfigComplete()
                }
            }
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
    
    func makeGlobalState(currentSceneIndex: Int? = nil,
                         grantUsers: Array<String>? = nil,
                         teacherFirstLogin: Bool? = nil) -> AgoraWhiteboardGlobalState {
        let newState = AgoraWhiteboardGlobalState()
        newState.currentSceneIndex = currentSceneIndex ?? globalState.currentSceneIndex
        newState.grantUsers = grantUsers ?? globalState.grantUsers
        newState.teacherFirstLogin = teacherFirstLogin ?? globalState.teacherFirstLogin
        
        return newState
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

        let boardStyles = """
                          var style = document.createElement('style');
                          style.innerHTML = `
                          /* tab titlebar background color */
                          .netless-window-manager-wrapper .telebox-titlebar {
                            background: \(blueColor);
                          }
                          /* tab title text color */
                          .netless-window-manager-wrapper .telebox-title {
                            color: \(whiteColor);
                          }
                          /* tab titlebar minimize button color */
                          .telebox-titlebar-icon-minimize {
                            background-image: url("data:image/svg+xml;utf8,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28"><path fill="\(whiteColor)" d="M9 13h10v1.6H9z"/></svg>')}")
                          }
                          /* tab titlebar maximize button color */
                          .telebox-titlebar-icon-maximize {
                            background-image: url("data:image/svg+xml;utf8,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28"><path fill="\(whiteColor)" d="M20.481 17.1h1.2v4.581H17.1v-1.2h3.381V17.1zm-14.1905-.009h1.2v3.381h3.3809v1.2h-4.581v-4.581zM17.1 6.1905h4.581v4.5809h-1.2v-3.381H17.1v-1.2zm-10.7008.1087h4.7985v1.2H7.5992v3.5985h-1.2V6.2992z"/></svg>')}")
                          }
                          /* tab titlebar close button color */
                          .telebox-titlebar-icon-close {
                            background-image: url("data:image/svg+xml;utf8,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28"><path stroke="\(whiteColor)" stroke-width="1.4" d="M8.353 20.3321L20.332 8.353M20.3322 20.3321L8.353 8.353"/></svg>')}")
                          }
                          /* foot view background color */
                          .netless-window-manager-wrapper .netless-app-docs-viewer-footer,
                          .netless-window-manager-wrapper .netless-app-slide-footer {
                            background: \(blueColor);
                          }
                          /* foot view text color */
                          .netless-window-manager-wrapper .netless-app-docs-viewer-page-number,
                          .netless-window-manager-wrapper .netless-app-slide-page-number-input {
                            color: \(whiteColor);
                          }
                          /* foot view number input text color */
                          .netless-window-manager-wrapper .netless-app-docs-viewer-footer,
                          .netless-window-manager-wrapper .netless-app-slide-footer {
                            color: \(whiteColor);
                          }
                          `
                          document.head.appendChild(style);
                          """
        
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
        let userScript = WKUserScript(source: boardStyles,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        ucc.addUserScript(userScript)
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
