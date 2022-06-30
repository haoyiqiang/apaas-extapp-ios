//
//  FcrBoardObjects.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/6.
//

import Foundation
import Whiteboard

struct FcrBoardError: Error {
    var code: Int
    var message : String
    
    static var sdkNil: FcrBoardError {
        return FcrBoardError(code: -1,
                             message: "whiteSDK nil")
    }
}

struct FcrColor: AgoraWidgetDescription {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    
    var toNetlessValue: [NSNumber] {
        let redItem = NSNumber.init(value: red)
        let greenItem = NSNumber.init(value: green)
        let blueItem = NSNumber.init(value: blue)
        
        let array = [redItem,
                     greenItem,
                     blueItem]
        
        return array
    }
    
    var agDescription: String {
        let dic = ["red": "\(red)",
                   "green": "\(green)",
                   "blue": "\(blue)"]
        return dic.agDescription
    }
}

struct FcrBoardRoomJoinConfig: AgoraWidgetDescription {
    var roomId: String
    var roomToken: String
    var boardRatio: Float
    var hasOperationPrivilege: Bool
    var userId: String
    var userName: String
    
    var agDescription: String {
        let dic = ["roomId": roomId,
                   "roomToken": roomToken,
                   "boardRatio": "\(boardRatio)",
                   "hasOperationPrivilege": "\(hasOperationPrivilege)",
                   "userId": userId,
                   "userName": userName]
        return dic.agDescription
    }
}

struct FcrBoardPageInfo: AgoraWidgetDescription {
    var showIndex: UInt16
    var count: UInt16
    
    var agDescription: String {
        let dic = ["showIndex": "\(showIndex)",
                   "count": "\(count)"]
        return dic.agDescription
    }
}

struct FcrBoardPage: AgoraWidgetDescription {
    var name: String
    var contentUrl: String
    var previewUrl: String?
    var contentWidth: Float
    var contentHeight: Float
    
    var toNetlessType: WhitePptPage {
        var page: WhitePptPage
        
        let size = CGSize(width: CGFloat(contentWidth),
                          height: CGFloat(contentHeight))
        
        if let `previewUrl` = previewUrl {
            page = WhitePptPage(src: contentUrl,
                                preview: previewUrl,
                                size: size)
        } else {
            page = WhitePptPage(src: contentUrl,
                                size: size)
        }
        
        return page
    }
    
    var agDescription: String {
        let dic = ["name": name,
                   "contentUrl": contentUrl,
                   "previewUrl": StringIsEmpty(previewUrl),
                   "contentWidth": "\(contentWidth)",
                   "contentHeight": "\(contentHeight)"]
        return dic.agDescription
    }
}

struct FcrBoardH5RegisterWindowConfig: AgoraWidgetDescription {
    /// url or jsString
    var resource: String
    var options: [String: Any]
    
    var agDescription: String {
        let dic = ["resource": resource,
                   "options": options.description]
        return dic.agDescription
    }
}

struct FcrBoardH5SubWindowConfig: AgoraWidgetDescription {
    /// H5 课件的 url
    var resourceUrl: String
    /// 窗口名
    var title: String
    
    var agDescription: String {
        let dic = ["resourceUrl": resourceUrl,
                   "title": title]
        return dic.agDescription
    }
}

struct FcrBoardSubWindowConfig: AgoraWidgetDescription {
    var resourceUuid: String
    var resourceHasAnimation: Bool
    var title: String
    var pageList: [FcrBoardPage]
    
    var agDescription: String {
        let dic = ["resourceUuid": resourceUuid,
                   "resourceHasAnimation": "\(resourceHasAnimation)",
                   "title": "\(title)",
                   "pageList": pageList.agDescription]
        return dic.agDescription
    }
}

struct FcrBoardMediaSubWindowConfig: AgoraWidgetDescription {
    var resourceUrl: String
    var title: String
    
    var agDescription: String {
        let dic = ["resourceUrl": resourceUrl,
                   "title": title]
        return dic.agDescription
    }
}

// MARK: - Netless extension
extension WKWebViewConfiguration {
    static func defaultConfig() -> WKWebViewConfiguration {
        let blueColor = "#75C0FF"
        let whiteColor = "#FFFFFF"
        let blackColor = "#000000"
        let testColor = "#CC00FF"
        
        // tab style
        let tabBGStyle = """
                         var style = document.createElement('style');
                         style.innerHTML = '.telebox-titlebar { background: \(whiteColor); }';
                         document.head.appendChild(style);
                         """
        
        let tabTitleStyle = """
                            var style = document.createElement('style');
                            style.innerHTML = '.telebox-title { color: \(blackColor); }';
                            document.head.appendChild(style);
                            """
        
        let footViewBGStyle = """
                              var style = document.createElement('style');
                              style.innerHTML = '.netless-app-docs-viewer-footer { background: \(whiteColor); }';
                              document.head.appendChild(style);
                              """
        
        let footViewPageLabelStyle = """
                                     var style = document.createElement('style');
                                     style.innerHTML = '.netless-app-docs-viewer-page-number { color: \(blackColor); }';
                                     document.head.appendChild(style);
                                     """
        
        let footViewPageButtonStyle = """
                                      var style = document.createElement('style');
                                      style.innerHTML = '.netless-window-manager-wrapper .telebox-title, .netless-window-manager-wrapper .netless-app-docs-viewer-footer { color: \(blackColor); }';
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
        // TODO: schemeHandler
//        if #available(iOS 11.0, *),
//           let handler = self.schemeHandler {
//            wkConfig.setURLSchemeHandler(handler,
//                                         forURLScheme: scheme)
//        }
        
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
}

extension Array where Element == FcrBoardPage {
    var toNetlessValue: [WhiteScene] {
        var array = [WhiteScene]()
        
        for item in self {
            let page = item.toNetlessType
            let scene = WhiteScene(name: item.name,
                                   ppt: page)
            
            array.append(scene)
        }
        
        return array
    }
}

extension WhiteSdkConfiguration: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["enableIFramePlugin": enableIFramePlugin.agDescription,
                   "region": region.debugDescription,
                   "useMultiViews": useMultiViews.agDescription]
        return dic.agDescription
    }
}

extension WhiteWindowParams: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["chessboard": chessboard.agDescription,
                   "containerSizeRatio": containerSizeRatio.floatValue.agDescription]
        return dic.agDescription
    }
}

extension WhiteRoomConfig: AgoraWidgetDescription {
    var agDescription: String {
        var userPayloadString: String
        
        if let payload = userPayload as? [String: String] {
            userPayloadString = payload.agDescription
        } else {
            userPayloadString = userPayload.debugDescription
        }
        
        let dic = ["uuid": uuid,
                   "roomToken": roomToken,
                   "uid": uid,
                   "userPayload": userPayloadString,
                   "isWritable": isWritable.agDescription,
                   "disableNewPencil": disableNewPencil.agDescription,
                   "windowParams": StringIsEmpty(windowParams?.agDescription)]
        
        return dic.agDescription
    }
}

extension WhiteMemberState: AgoraWidgetDescription {
    var agDescription: String {
        // strokeColor
        var strokeColorText: String?
        
        if let `strokeColor` = strokeColor {
            var itemsText = [String]()
            
            for item in strokeColor {
                itemsText.append(item.intValue.agDescription)
            }
            
            if itemsText.count > 0  {
                strokeColorText = itemsText.agDescription
            }
        }
        
        // strokeWidth
        var strokeWidthText: String?
        
        if let `strokeWidth` = strokeWidth {
            strokeWidthText = strokeWidth.intValue.agDescription
        }
        
        // textSize
        var textSizeText: String?
        
        if let `textSize` = textSize {
            textSizeText = textSize.intValue.agDescription
        }
        
        var dic = ["currentApplianceName": StringIsEmpty(currentApplianceName?.rawValue),
                   "strokeColor": StringIsEmpty(strokeColorText),
                   "strokeWidth": StringIsEmpty(strokeWidthText),
                   "textSize": StringIsEmpty(textSizeText),
                   "shapeType": StringIsEmpty(shapeType?.rawValue)]
        
        return dic.agDescription
    }
}

extension WhitePageState: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["index": index.agDescription,
                   "length": length.agDescription]
        return dic.agDescription
    }
    
    var toFcr: FcrBoardPageInfo {
        let info = FcrBoardPageInfo(showIndex: UInt16(index),
                                    count: UInt16(length))
        
        return info
    }
}

extension WhitePptPage: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["src": src,
                   "width": width.agDescription,
                   "height": height.agDescription,
                   "previewURL": StringIsEmpty(previewURL)]
        return dic.agDescription
    }
}

extension WhiteScene: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["name": name,
                   "ppt": StringIsEmpty(ppt?.agDescription)]
        return dic.agDescription
    }
}
