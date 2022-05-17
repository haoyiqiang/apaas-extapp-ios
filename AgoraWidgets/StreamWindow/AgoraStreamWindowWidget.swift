//
//  AgoraStreamWindowWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/25.
//

import AgoraWidget

@objcMembers public class AgoraStreamWindowWidget: AgoraBaseWidget, AgoraWidgetLogTube {
    var logger: AgoraWidgetLogger
    
    var renderInfo: AgoraStreamWindowRenderInfo?
    
    override init(widgetInfo: AgoraWidgetInfo) {
        let logger = AgoraWidgetLogger(widgetId: widgetInfo.widgetId)
        #if DEBUG
        logger.isPrintOnConsole = true
        #endif
        self.logger = logger
        
        super.init(widgetInfo: widgetInfo)
        
        log(content: "[StreamWindow Widget]:create",
            extra: "widgetId:\(widgetInfo.widgetId)",
            type: .info)
    }
    
    public override func onLoad() {
//        initData()
    }
    
    public override func onWidgetRoomPropertiesUpdated(_ properties: [String : Any],
                                                       cause: [String : Any]?,
                                                       keyPaths: [String],
                                                       operatorUser: AgoraWidgetUserInfo?) {
//        if renderInfo == nil {
//            initData()
//        } else {
            updateExtra(properties: properties)
//        }
    }
}

private extension AgoraStreamWindowWidget {
    func sendMessage(_ signal: AgoraStreamWindowInteractionSignal) {
        if let message = signal.toMessageString() {
            sendMessage(message)
        }
    }
    
    func initData() {
        let streamId = String(info.widgetId.split(separator: "-")[1])
        
        guard let propsDic = info.roomProperties as? Dictionary<String, Any>,
              let info = AgoraStreamWindowExtraInfo.decode(propsDic),
              streamId != "" else {
            return
        }
        
        let renderInfo = AgoraStreamWindowRenderInfo(userUuid: info.userUuid,
                                                     streamId: streamId,
                                                     zIndex: info.zIndex)
        self.renderInfo = renderInfo
        log(content: "[StreamWindow Widget]:send render info",
            extra: "userUuid:\(info.userUuid),streamId:\(streamId)",
            type: .info)
        sendMessage(.RenderInfo(renderInfo))
    }
    
    func updateExtra(properties: [String : Any]) {
        guard let index = properties["zIndex"] as? Int else {
            return
        }
        sendMessage(.ViewZIndex(index))
    }
}
