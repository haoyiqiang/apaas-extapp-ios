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
