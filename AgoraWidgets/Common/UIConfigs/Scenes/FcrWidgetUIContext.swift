//
//  FcrWidgetUIContext.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/8/4.
//

import Foundation

@objc public class FcrWidgetUIContext: NSObject {
    @objc public static func create(with type: FcrWidgetUISceneType) {
        switch type {
        case .oneToOne: UIConfig = FcrWidgetOneToOneUIConfig()
        case .small:    UIConfig = FcrWidgetSmallUIConfig()
        case .lecture:  UIConfig = FcrWidgetLectrueUIConfig()
        case .vocation: UIConfig = FcrWidgetLectrueUIConfig()
        }
    }
    
    @objc public static func desctory() {
        UIConfig = nil
    }
}
