//
//  FcrBoardEnums.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/6/6.
//

import Foundation
import Whiteboard

enum FcrBoardLogType: Int {
    case info    = 1
    case warning = 2
    case error   = 3
}

enum FcrBoardRoomConnectionState: Int, AgoraWidgetDescription {
    case connecting    = 0
    case connected     = 1
    case reconnecting  = 2
    case disconnecting = 3
    case disconnected  = 4
    
    var agDescription: String {
        switch self {
        case .connecting:    return "connecting"
        case .connected:     return "connected"
        case .reconnecting:  return "reconnecting"
        case .disconnecting: return "disconnecting"
        case .disconnected:  return "disconnected"
        }
    }
}

enum FcrBoardToolType: Int, AgoraWidgetDescription {
    case none         = 0
    case selector     = 1
    case laserPointer = 2
    case eraser       = 3
    
    var toNetlessValue: WhiteApplianceNameKey {
        switch self {
        case .none:         return .ApplianceClicker
        case .selector:     return .ApplianceSelector
        case .laserPointer: return .ApplianceLaserPointer
        case .eraser:       return .ApplianceEraser
        }
    }
    
    var agDescription: String {
        switch self {
        case .none:         return "none"
        case .selector:     return "selector"
        case .laserPointer: return "laserPointer"
        case .eraser:       return "eraser"
        }
    }
}

enum FcrBoardDrawShape: Int, AgoraWidgetDescription {
    case curve     = 1
    case straight  = 2
    case arrow     = 3
    case rectangle = 4
    case triangle  = 5
    case rhombus   = 6
    case pentagram = 7
    case ellipse   = 8
    
    var toNetlessValue: WhiteApplianceNameKey? {
        switch self {
        case .curve:     return .AppliancePencil
        case .straight:  return .ApplianceStraight
        case .arrow:     return .ApplianceArrow
        case .rectangle: return .ApplianceRectangle
        case .ellipse:   return .ApplianceEllipse
        default:         return nil
        }
    }
    
    var toNetlessType: WhiteApplianceShapeTypeKey? {
        switch self {
        case .triangle:  return .ApplianceShapeTypeTriangle
        case .rhombus:   return .ApplianceShapeTypeRhombus
        case .pentagram: return .ApplianceShapeTypePentagram
        default:         return nil
        }
    }
    
    var agDescription: String {
        switch self {
        case .curve:     return "none"
        case .straight:  return "straight"
        case .arrow:     return "arrow"
        case .rectangle: return "rectangle"
        case .ellipse:   return "ellipse"
        case .triangle:  return "triangle"
        case .rhombus:   return "rhombus"
        case .pentagram: return "pentagram"
        }
    }
}

enum FcrBoardRegion: String {
    case cn   = "cn-hz"
    case us   = "us-sv"
    case `in` = "in-mum"
    case sg   = "sg"
    case gb   = "gb-lon"
    
    var netlessValue: WhiteRegionKey {
        switch self {
        case .cn: return .CN
        case .us: return .US
        case .in: return .IN
        case .sg: return .SG
        case .gb: return .GB
        }
    }
}

extension WhiteRoomPhase: AgoraWidgetDescription {
    var fcrType: FcrBoardRoomConnectionState {
        switch self {
        case .connecting:    return .connecting
        case .connected:     return .connected
        case .reconnecting:  return .reconnecting
        case .disconnecting: return .disconnecting
        case .disconnected:  return .disconnected
        }
    }
    
    var agDescription: String {
        switch self {
        case .connecting:    return "connecting"
        case .connected:     return "connected"
        case .reconnecting:  return "reconnecting"
        case .disconnecting: return "disconnecting"
        case .disconnected:  return "disconnected"
        }
    }
}
