//
//  AgoraWidgetDescription.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/8.
//

import Foundation

protocol AgoraWidgetDescription {
    var agDescription: String { get }
}

func StringIsEmpty(_ text: String?) -> String {
    if let `text` = text {
        return text
    } else {
        return "nil"
    }
}

extension Array where Element: AgoraWidgetDescription {
    var agDescription: String {
        var array = [String]()
        
        for i in 0..<count {
            let item = self[i]
            array.append(item.agDescription)
        }
        
        let string = array.joined(separator: ", ")
        return "[" + string + "]"
    }
}

extension Dictionary: AgoraWidgetDescription where Key == String, Value: AgoraWidgetDescription {
    var agDescription: String {
        var array = [String]()
        
        for (key, value) in self {
            array.append("\(key): \(value.agDescription)")
        }
        
        let string = array.joined(separator: ", ")
        return "[" + string + "]"
    }
}

extension String: AgoraWidgetDescription {
    var agDescription: String {
        return description
    }
}

extension CGSize: AgoraWidgetDescription {
    var agDescription: String {
        let dic = ["width": "\(width)",
                   "height": "\(height)"]
        return dic.agDescription
    }
}

extension Bool: AgoraWidgetDescription {
    var agDescription: String {
        return "\(self)"
    }
}

extension Float: AgoraWidgetDescription {
    var agDescription: String {
        return "\(self)"
    }
}

extension Int: AgoraWidgetDescription {
    var agDescription: String {
        return "\(self)"
    }
}

extension UInt16: AgoraWidgetDescription {
    var agDescription: String {
        return "\(self)"
    }
}

extension CGFloat: AgoraWidgetDescription {
    var agDescription: String {
        return "\(self)"
    }
}
