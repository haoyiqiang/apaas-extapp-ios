//
//  AgoraColorGroup.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

@objc public enum FcrWidgetsUIMode: Int {
    case agoraLight = 0
    case agoraDark = 1
}

@objc public enum FcrWidgetsLanguage: Int {
    case followSystem = 0
    case simplified = 1
    case english = 2
}

@objc public class FcrWidgetsUIGlobal: NSObject {
    
    @objc public class func setUIMode(uiMode: FcrWidgetsUIMode, language: FcrWidgetsLanguage) {
        FcrWidgetsUIGlobal.uiMode = uiMode
        FcrWidgetsUIGlobal.launguage = language
    }
    
    static var uiMode: FcrWidgetsUIMode = .agoraLight
    
    static var launguage: FcrWidgetsLanguage = .followSystem {
        didSet {
            guard launguage != oldValue else {
                return
            }
            var languageSimble = ""
            switch launguage {
            case .followSystem:
                languageSimble = "empty"
            case .simplified:
                languageSimble = "zh-Hans"
            case .english:
                languageSimble = "en"
            }
            if let eduUIBundle = Bundle.agora_bundle("AgoraWidgets"),
               let languagePath = eduUIBundle.path(forResource: languageSimble,
                                                   ofType: "lproj") {
                languageBundle = Bundle(path: languagePath)
            } else {
                languageBundle = nil
            }
        }
    }
    // 当前使用的语言包
    static var languageBundle: Bundle?
    
}

@objc public extension NSString {
    func widgets_localized() -> String {
        let bundle = FcrWidgetsUIGlobal.languageBundle ?? Bundle.agora_bundle("AgoraWidgets") ?? Bundle.main
        return bundle.localizedString(forKey: self as String,
                                      value: nil,
                                      table: nil)
    }
}
