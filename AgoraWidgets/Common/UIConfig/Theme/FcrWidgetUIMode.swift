//
//  AgoraColorGroup.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

enum FcrWidgetUIMode: Int {
    case agoraLight
    case agoraDark
}

var UIMode: FcrWidgetUIMode = .agoraLight

//var UIMode: FcrWidgetUIMode {
//    get {
//        var mode: FcrWidgetUIMode = .agoraLight
//        
//        if #available(iOS 13.0, *) {
//            let topVc = UIViewController.ag_topViewController()
//            let style = topVc.overrideUserInterfaceStyle
//            
//            mode = (style == .light ? .agoraLight : .agoraDark)
//        }
//        
//        return mode
//    }
//}

