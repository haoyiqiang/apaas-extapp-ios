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
}

class AgoraFrameGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
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
        return 40
    }
}

class AgoraFontGroup {
    fileprivate var mode: AgoraUIMode
    
    init() {
        self.mode = Mode
    }
    
    var poll_label_font: UIFont {
        return UIFont.systemFont(ofSize: 9)
    }
}
