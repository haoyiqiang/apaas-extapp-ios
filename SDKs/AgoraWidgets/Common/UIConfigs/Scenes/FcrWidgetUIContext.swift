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
        case .lecture:  UIConfig = FcrWidgetLectureUIConfig()
        case .vocation: UIConfig = FcrWidgetLectureUIConfig()
        }
    }
    
    @objc public static func destroy() {
//        UIConfig = nil
    }
}
