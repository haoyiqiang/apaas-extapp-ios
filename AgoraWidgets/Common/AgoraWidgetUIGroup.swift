//
//  AgoraWidgetUIGroup.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/18.
//

import UIKit

fileprivate enum AgoraUIMode {
    case agoraLight
}

fileprivate let Mode: AgoraUIMode = .agoraLight

class AgoraUIGroup {
    let color = AgoraColorGroup()
    let frame = AgoraFrameGroup()
    let font = AgoraFontGroup()
}

class AgoraColorGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    // cloud
    var cloud_header_1_bg_color: UIColor = UIColor(hex: 0xF9F9FC)!
    var cloud_header_2_bg_color: UIColor = UIColor.white
    var cloud_select_line_color: UIColor = UIColor(hex: 0x0073FF)!
    var cloud_label_color: UIColor = UIColor(hex: 0x191919)!
    var cloud_file_name_label_color: UIColor = UIColor(hex: 0x7B88A0)!
    var cloud_sep_line_color: CGColor = UIColor(hex: 0xEEEEF7)!.cgColor
    var cloud_search_bar_border_color: CGColor = UIColor(hex: 0xD7D7E6)!.cgColor
    
    // webView
    var web_title_color = UIColor(hex: 0x191919)
    var web_border_color: CGColor = UIColor(hex: 0xE3E3EC)!.cgColor
}

class AgoraFrameGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    // common
    var border_width: CGFloat = 1
    
    // Poll
    // title
    var poll_title_label_horizontal_space: CGFloat {
        return 15
    }
    
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
    
    // cloud
    var cloud_bg_corner_radius: CGFloat = 6
    var cloud_search_bar_corner_radius: CGFloat = 4
    
    // webView
    var web_button_spacing: CGFloat = 12
    var web_button_length: CGFloat = 20
    var web_title_side_gap: CGFloat = 15
    var web_corner_radius: CGFloat = 4
}

class AgoraFontGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    var poll_label_font: UIFont {
        return UIFont.systemFont(ofSize: 9)
    }
    
    // cloud
    var cloud_label_font = UIFont.systemFont(ofSize: 12)
    
    // webView
    var web_title_font = UIFont.systemFont(ofSize: 12)
}
