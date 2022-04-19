//
//  AgoraBoardModels.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2021/12/3.
//

import Foundation

/// 对应AgoraBoardWidgetModel
// MARK: - Config
enum AgoraBoardInteractionSignal: Convertable {
    case JoinBoard
    case BoardPhaseChanged(AgoraBoardRoomPhase)
    case MemberStateChanged(AgoraBoardMemberState)
    case GetBoardGrantedUsers([String])
    case UpdateGrantedUsers(AgoraBoardGrantUsersChangeType)
    case AudioMixingStateChanged(AgoraBoardAudioMixingData)
    case BoardAudioMixingRequest(AgoraBoardAudioMixingRequestData)
    case BoardPageChanged(AgoraBoardPageChangeType)
    case BoardStepChanged(AgoraBoardStepChangeType)
    case ClearBoard
    case OpenCourseware(AgoraBoardCoursewareInfo)
    case WindowStateChanged(AgoraBoardWindowState)
    case CloseBoard
    
    private enum CodingKeys: CodingKey {
        case JoinBoard
        case BoardPhaseChanged
        case MemberStateChanged
        case GetBoardGrantedUsers
        case UpdateGrantedUsers
        case AudioMixingStateChanged
        case BoardAudioMixingRequest
        case BoardPageChanged
        case BoardStepChanged
        case ClearBoard
        case OpenCourseware
        case WindowStateChanged
        case CloseBoard
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .JoinBoard) {
            self = .JoinBoard
        } else if let value = try? container.decode(AgoraBoardRoomPhase.self,
                                                    forKey: .BoardPhaseChanged) {
            self = .BoardPhaseChanged(value)
        } else if let value = try? container.decode(AgoraBoardMemberState.self,
                                                    forKey: .MemberStateChanged) {
            self = .MemberStateChanged(value)
        } else if let value = try? container.decode(AgoraBoardAudioMixingData.self,
                                                    forKey: .AudioMixingStateChanged) {
            self = .AudioMixingStateChanged(value)
        } else if let value = try? container.decode([String].self,
                                                    forKey: .GetBoardGrantedUsers) {
            self = .GetBoardGrantedUsers(value)
        } else if let value = try? container.decode(AgoraBoardGrantUsersChangeType.self,
                                                    forKey: .UpdateGrantedUsers) {
            self = .UpdateGrantedUsers(value)
        } else if let value = try? container.decode(AgoraBoardPageChangeType.self,
                                                    forKey: .BoardPageChanged) {
            self = .BoardPageChanged(value)
        } else if let value = try? container.decode(AgoraBoardStepChangeType.self,
                                                    forKey: .BoardStepChanged) {
            self = .BoardStepChanged(value)
        } else if let value = try? container.decodeNil(forKey: .ClearBoard) {
            self = .ClearBoard
        } else if let value = try? container.decode(AgoraBoardCoursewareInfo.self,
                                                    forKey: .OpenCourseware) {
            self = .OpenCourseware(value)
        } else if let value = try? container.decode(AgoraBoardWindowState.self,
                                                    forKey: .WindowStateChanged) {
            self = .WindowStateChanged(value)
        } else if let _ = try? container.decodeNil(forKey: .CloseBoard) {
            self = .CloseBoard
        } else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "invalid data"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .JoinBoard:
            try container.encodeNil(forKey: .JoinBoard)
        case .BoardPhaseChanged(let x):
            try container.encode(x,
                                 forKey: .BoardPhaseChanged)
        case .MemberStateChanged(let x):
            try container.encode(x,
                                 forKey: .MemberStateChanged)
        case .GetBoardGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .GetBoardGrantedUsers)
        case .UpdateGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .UpdateGrantedUsers)
        case .AudioMixingStateChanged(let x):
            try container.encode(x,
                                 forKey: .AudioMixingStateChanged)
        case .BoardAudioMixingRequest(let x):
            try container.encode(x,
                                 forKey: .BoardAudioMixingRequest)
        case .BoardPageChanged(let x):
            try container.encode(x,
                                 forKey: .BoardPageChanged)
        case .BoardStepChanged(let x):
            try container.encode(x,
                                 forKey: .BoardStepChanged)
        case .ClearBoard:
            try container.encodeNil(forKey: .ClearBoard)
        case .OpenCourseware(let x):
            try container.encode(x,
                                 forKey: .OpenCourseware)
        case .WindowStateChanged(let x):
            try container.encode(x,
                                 forKey: .WindowStateChanged)
        case .CloseBoard:
            try container.encodeNil(forKey: .CloseBoard)
        }
    }
    
    func toMessageString() -> String? {
        guard let dic = self.toDictionary(),
           let str = dic.jsonString() else {
            return nil
        }
        return str
    }
}

enum AgoraBoardRoomPhase: Int, Convertable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};

enum AgoraBoardToolType: Int, Convertable {
    case Selector, Text, Rectangle, Ellipse, Eraser, Pencil, Arrow, Straight, Pointer, Clicker, Shape
}

enum AgoraBoardToolShapeType: Int, Convertable {
    case Triangle, Rhombus, Pentagram, Ballon
}

enum AgoraBoardWindowState: Int, Convertable {
    case min, max, normal
}

// MARK: - Message
// 当外部手动更新某一项数据的时候MemberState就只包含对应的某一项，然后通过sendMessageToWidget发送即可
// 若初始化时期，白板需要向外传
struct AgoraBoardMemberState: Convertable {
    // 被激活教具
    var activeApplianceType: AgoraBoardToolType?
    // 颜色
    var strokeColor: Array<Int>?
    // 线条宽度
    var strokeWidth: Int?
    // 文字大小
    var textSize: Int?
    // 图形
    var shapeType: AgoraBoardToolShapeType?
    
    init(activeApplianceType: AgoraBoardToolType?,
         strokeColor: Array<Int>?,
         strokeWidth: Int?,
         textSize: Int?,
         shapeType: AgoraBoardToolShapeType?) {
        self.activeApplianceType = activeApplianceType
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textSize = textSize
        self.shapeType = shapeType
    }
}

struct AgoraBoardAudioMixingData: Convertable {
    var stateCode: Int
    var errorCode: Int
}

enum AgoraBoardAudioMixingRequestType: Int,Convertable {
    case start,stop,setPosition
}

struct AgoraBoardAudioMixingRequestData: Convertable {
    var requestType: AgoraBoardAudioMixingRequestType
    var filePath: String
    var loopback: Bool
    var replace: Bool
    var cycle: Int
    var position: Int
    
    init(requestType: AgoraBoardAudioMixingRequestType,
         filePath: String = "",
         loopback: Bool = true,
         replace: Bool = true,
         cycle: Int = 0,
         position: Int = 0) {
        self.requestType = requestType
        self.filePath = filePath
        self.loopback = loopback
        self.replace = replace
        self.cycle = cycle
        self.position = position
    }
}

// page handle
struct AgoraBoardPageInfo: Convertable {
    var index: Int
    var count: Int
}

enum AgoraBoardPageChangeType: Convertable {
    case index(Int)
    case count(Int)
    
    private enum CodingKeys: CodingKey {
        case index
        case count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let type1Value = try? container.decode(Int.self, forKey: .index) {
            self = .index(type1Value)
        } else {
            let type2Value = try container.decode(Int.self, forKey: .count)
            self = .count(type2Value)
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .index(let value):
            try container.encode(value, forKey: .index)
        case .count(let value):
            try container.encode(value, forKey: .count)
        }
    }
}

// grant
enum AgoraBoardGrantUsersChangeType: Convertable {
    case add([String])
    case delete([String])
    
    private enum CodingKeys: CodingKey {
        case add
        case delete
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode([String].self,
                                         forKey: .add) {
            self = .add(x)
        } else if let x = try? container.decode([String].self,
                                                forKey: .delete) {
            self = .delete(x)
        } else {
            throw DecodingError.typeMismatch(AgoraBoardStepChangeType.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for AgoraBoardGrantUsersChangeType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .add(let x):
            try container.encode(x,
                                 forKey: .add)
        case .delete(let x):
            try container.encode(x,
                                 forKey: .delete)
        }
    }
}

// step
enum AgoraBoardStepChangeType: Convertable {
    case pre(Int)
    case next(Int)
    case undoCount(Int)
    case redoCount(Int)
    
    private enum CodingKeys: CodingKey {
        case pre
        case next
        case undoCount
        case redoCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode(Int.self,
                                         forKey: .pre) {
            self = .pre(x)
        } else if let x = try? container.decode(Int.self,
                                         forKey: .next) {
            self = .next(x)
        } else if let x = try? container.decode(Int.self,
                                         forKey: .undoCount) {
            self = .undoCount(x)
        } else if let x = try? container.decode(Int.self,
                                                forKey: .redoCount) {
            self = .redoCount(x)
        } else {
            throw DecodingError.typeMismatch(AgoraBoardStepChangeType.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for AgoraBoardWidgetStepChangeType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pre(let x):
            try container.encode(x,
                                 forKey: .pre)
        case .next(let x):
            try container.encode(x,
                                 forKey: .next)
        case .undoCount(let x):
            try container.encode(x,
                                 forKey: .undoCount)
        case .redoCount(let x):
            try container.encode(x,
                                 forKey: .redoCount)
        }
    }
}

// courseware
struct AgoraBoardCoursewareInfo: Convertable {
    var resourceUuid: String
    var resourceName: String
    var resourceUrl: String
    var scenes: [AgoraBoardWhiteScene]?
    var convert: Bool?
    
    init(resourceName: String,
         resourceUuid: String,
         resourceUrl: String,
         scenes: [AgoraBoardWhiteScene]?,
         convert: Bool?) {
        self.resourceName = resourceName
        self.resourceUuid = resourceUuid
        self.resourceUrl = resourceUrl
        self.scenes = scenes
        self.convert = convert
    }
    
    init(publicCourseware: AgoraBoardPublicCourseware) {
        self.init(resourceName: publicCourseware.resourceName,
                  resourceUuid: publicCourseware.resourceUuid,
                  resourceUrl: publicCourseware.url,
                  scenes: publicCourseware.taskProgress?.convertedFileList,
                  convert: publicCourseware.conversion?.canvasVersion)
    }
}

struct AgoraBoardWhiteScene: Convertable {
    var name: String
    var ppt: AgoraBoardWhitePptPage
}

struct AgoraBoardWhitePptPage: Convertable {
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
}

// MARK: - public coursewares
struct AgoraBoardPublicCourseware: Convertable {
    let resourceUuid: String
    let resourceName: String
    let ext: String
    let size: Int64
    let url: String
    let updateTime: Int64
    let taskUuid: String?
    let conversion: AgoraBoardPublicConversion?
    let taskProgress: AgoraBoardTaskProgress?
}

struct AgoraBoardPublicConversion: Convertable {
    let type: String
    let preview: Bool
    let scale: Double
    let outputFormat: String
    let canvasVersion: Bool?
}

struct AgoraBoardTaskProgress: Convertable {
    let status: String?
    let totalPageSize: Int64
    let convertedPageSize: Int64
    let convertedPercentage: Int64
    let currentStep: String?
    let convertedFileList: [AgoraBoardWhiteScene]
}

// MARK: - common extension
extension Array where Element == AgoraBoardPublicCourseware {
    func toCoursewareList() -> Array<AgoraBoardCoursewareInfo> {
        var configs = Array<AgoraBoardCoursewareInfo>()
        for item in self {
            var config = AgoraBoardCoursewareInfo(publicCourseware: item)
            configs.append(config)
        }
        return configs
    }
}
