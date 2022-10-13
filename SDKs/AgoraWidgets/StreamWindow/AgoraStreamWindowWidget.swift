//
//  AgoraStreamWindowWidget.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/25.
//

import AgoraWidget

@objcMembers public class AgoraStreamWindowWidget: AgoraNativeWidget {
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
