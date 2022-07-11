//
//  AgoraWidgetUIGroup.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/18.
//

import UIKit

@objc public enum AgoraUIMode: Int {
    case agoraLight
    case agoraDark
}

fileprivate var Mode: AgoraUIMode {
    get {
        if #available(iOS 13.0, *) {
            let topVc = UIViewController.ag_topViewController()
            let style = topVc.overrideUserInterfaceStyle
            return (style == .dark) ? .agoraDark : .agoraLight
        } else {
            return .agoraLight
        }
        
    }
}

class AgoraUIGroup {
    let frame = AgoraFrameGroup()
    let font = AgoraFontGroup()
}

class AgoraFrameGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    // corner radius
    var fcr_window_corner_radius: CGFloat = 2
    var fcr_toast_corner_radius: CGFloat = 4
    var fcr_button_corner_radius: CGFloat = 6
    var fcr_alert_corner_radius: CGFloat = 12
    var fcr_round_container_corner_radius: CGFloat = 16
    var fcr_square_container_corner_radius: CGFloat = 10
    
    // border width
    var fcr_border_width: CGFloat = 1
    
    // alert side spacing
    var fcr_alert_side_spacing: CGFloat = 30
    
    // Poll
    // option cell
    var poll_option_label_vertical_space: CGFloat {
        return 5
    }
    
    var poll_option_label_left_space: CGFloat {
        return 37
    }
    
    var poll_option_label_right_space: CGFloat {
        return 15
    }
    
    // result cell
    var poll_result_label_horizontal_space: CGFloat {
        return 15
    }
    
    var poll_result_label_vertical_space: CGFloat {
        return 5
    }
    
    var poll_result_value_label_width: CGFloat {
        return 50
    }
}

class AgoraFontGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    var fcr_font17: UIFont = .systemFont(ofSize: 17)
    var fcr_font14: UIFont = .systemFont(ofSize: 14)
    var fcr_font13: UIFont = .systemFont(ofSize: 13)
    var fcr_font12: UIFont = .systemFont(ofSize: 12)
    var fcr_font11: UIFont = .systemFont(ofSize: 11)
    var fcr_font10: UIFont = .systemFont(ofSize: 10)
    var fcr_font9: UIFont  = .systemFont(ofSize: 9)
}
