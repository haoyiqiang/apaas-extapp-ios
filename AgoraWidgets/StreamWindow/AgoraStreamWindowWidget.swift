//
//  AgoraStreamWindowWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/25.
//

import AgoraWidget

@objcMembers public class AgoraStreamWindowWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    var logger: AgoraWidgetLogger
    
    override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId,
                                       logId: widgetInfo.localUserInfo.userUuid)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
        
        log(content: "[StreamWindow Widget]:create",
            extra: "widgetId:\(widgetInfo.widgetId)",
            type: .info)
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
        super.onWidgetRoomPropertiesUpdated(properties,
                                            cause: cause,
                                            keyPaths: keyPaths,
                                            operatorUser: operatorUser)
        
        guard let zIndex = properties["zIndex"] as? Int else {
            return
        }
        
        let messageDic = ["zIndex": zIndex]
        
        guard let message = messageDic.jsonString() else {
            return
        }
        
        sendMessage(message)
    }
}
