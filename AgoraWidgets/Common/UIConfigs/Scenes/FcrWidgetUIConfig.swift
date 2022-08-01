//
//  FcrUIConfig.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/7/11.
//

import UIKit

protocol FcrWidgetUIConfig {
    var streamWindow: FcrWidgetUIComponentStreamWindow { get }
    var webView: FcrWidgetUIComponentWebView { get }
    var popupQuiz: FcrWidgetUIComponentPopupQuiz { get }
    var counter: FcrWidgetUIComponentCounter { get }
    var poll: FcrWidgetUIComponentPoll { get }
    var cloudStorage: FcrWidgetUIComponentCloudStorage { get }
    var netlessBoard: FcrWidgetUIComponentNetlessBoard { get }
    var agoraChat: FcrWidgetUIComponentAgoraChat { get }
}

var UIConfig: FcrWidgetUIConfig!

@objc public class FcrWidgetsUIConfigOC: NSObject {
    @objc public static func setUIConfig(value: Int) {
        set_ui_config(value: value)
    }

    @objc public static func relaseUIConfig() {
        relase_ui_config()
    }
}

public func set_ui_config(value: Int) {
    switch value {
    // One to one
    case 0:
        UIConfig = FcrWidgetOneToOneUIConfig()
    // Small
    case 1:
        UIConfig = FcrWidgetSmallUIConfig()
    // Lecture
    case 3:
        UIConfig = FcrWidgetLectrueUIConfig()
    default:
        fatalError("invalid value: \(value)")
    }
}

public func relase_ui_config() {
    UIConfig = nil
}
