//
//  FcrBoardModels.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/6/14.
//

import Foundation

// MARK: signal
enum FcrBoardInteractionSignal: Convertable {
    case joinBoard
    case changeAssistantType(FcrBoardAssistantType)
    case getBoardGrantedUsers([String])
    case updateGrantedUsers(FcrBoardGrantUsersChangeType)
    case audioMixingStateChanged(FcrBoardAudioMixingData)
    case boardAudioMixingRequest(FcrBoardAudioMixingRequestData)
    case boardStepChanged(FcrBoardStepChangeType)
    case clearBoard
    case openCourseware(FcrBoardCoursewareInfo)
    case windowStateChanged(FcrBoardWindowState)
    case saveBoard
    case changeRatio
    case onBoardSaveResult(FcrBoardSnapshotResult)
    case closeBoard
    
    private enum CodingKeys: CodingKey {
        case joinBoard
        case BoardPhaseChanged
        case changeAssistantType
        case getBoardGrantedUsers
        case updateGrantedUsers
        case audioMixingStateChanged
        case boardAudioMixingRequest
        case BoardPageChanged
        case boardStepChanged
        case clearBoard
        case openCourseware
        case windowStateChanged
        case saveBoard
        case changeRatio
        case onBoardSaveResult
        case closeBoard
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .joinBoard) {
            self = .joinBoard
        } else if let value = try? container.decode(FcrBoardAssistantType.self,
                                                    forKey: .changeAssistantType) {
            self = .changeAssistantType(value)
        } else if let value = try? container.decode(FcrBoardAudioMixingData.self,
                                                    forKey: .audioMixingStateChanged) {
            self = .audioMixingStateChanged(value)
        } else if let value = try? container.decode([String].self,
                                                    forKey: .getBoardGrantedUsers) {
            self = .getBoardGrantedUsers(value)
        } else if let value = try? container.decode(FcrBoardGrantUsersChangeType.self,
                                                    forKey: .updateGrantedUsers) {
            self = .updateGrantedUsers(value)
        } else if let value = try? container.decode(FcrBoardStepChangeType.self,
                                                    forKey: .boardStepChanged) {
            self = .boardStepChanged(value)
        } else if let value = try? container.decodeNil(forKey: .clearBoard) {
            self = .clearBoard
        } else if let value = try? container.decode(FcrBoardCoursewareInfo.self,
                                                    forKey: .openCourseware) {
            self = .openCourseware(value)
        } else if let value = try? container.decode(FcrBoardWindowState.self,
                                                    forKey: .windowStateChanged) {
            self = .windowStateChanged(value)
        } else if let _ = try? container.decodeNil(forKey: .saveBoard) {
            self = .saveBoard
        } else if let _ = try? container.decodeNil(forKey: .changeRatio) {
            self = .changeRatio
        } else if let value = try? container.decode(FcrBoardSnapshotResult.self,
                                                    forKey: .onBoardSaveResult) {
            self = .onBoardSaveResult(value)
        } else if let _ = try? container.decodeNil(forKey: .closeBoard) {
            self = .closeBoard
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
        case .joinBoard:
            try container.encodeNil(forKey: .joinBoard)
        case .changeAssistantType(let x):
            try container.encode(x,
                                 forKey: .changeAssistantType)
        case .getBoardGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .getBoardGrantedUsers)
        case .updateGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .updateGrantedUsers)
        case .audioMixingStateChanged(let x):
            try container.encode(x,
                                 forKey: .audioMixingStateChanged)
        case .boardAudioMixingRequest(let x):
            try container.encode(x,
                                 forKey: .boardAudioMixingRequest)
        case .boardStepChanged(let x):
            try container.encode(x,
                                 forKey: .boardStepChanged)
        case .clearBoard:
            try container.encodeNil(forKey: .clearBoard)
        case .openCourseware(let x):
            try container.encode(x,
                                 forKey: .openCourseware)
        case .windowStateChanged(let x):
            try container.encode(x,
                                 forKey: .windowStateChanged)
        case .saveBoard:
            try container.encodeNil(forKey: .saveBoard)
        case .changeRatio:
            try container.encodeNil(forKey: .changeRatio)
        case .onBoardSaveResult(let x):
            try container.encode(x,
                                 forKey: .onBoardSaveResult)
        case .closeBoard:
            try container.encodeNil(forKey: .closeBoard)
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

// MARK: - audiomixing
struct FcrBoardAudioMixingData: Convertable {
    var stateCode: Int
    var errorCode: Int
}

enum FcrBoardAudioMixingRequestType: Int,Convertable {
    case start,stop,setPosition
}

struct FcrBoardAudioMixingRequestData: Convertable {
    var requestType: FcrBoardAudioMixingRequestType
    var filePath: String
    var loopback: Bool
    var replace: Bool
    var cycle: Int
    var position: Int
    
    init(requestType: FcrBoardAudioMixingRequestType,
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

// MARK: - grant
enum FcrBoardGrantUsersChangeType: Convertable {
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
            throw DecodingError.typeMismatch(FcrBoardStepChangeType.self,
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

// save snapshot
enum FcrBoardSnapshotResult: Int, Convertable {
    case savedToAlbum, noAlbumAuth, failureToSave
}

// window
enum FcrBoardWindowState: Int, Convertable {
    case min, max, normal
}

extension FcrWindowBoxState {
    var toWidget: FcrBoardWindowState {
        switch self {
        case .normal:   return .normal
        case .mini:     return .min
        case .max:      return .max
        }
    }
}

// courseware
struct FcrBoardCoursewareInfo: Convertable {
    var resourceUuid: String
    var resourceName: String
    var resourceUrl: String
    var scenes: [FcrBoardScene]?
    var convert: Bool?
    
    init(resourceName: String,
         resourceUuid: String,
         resourceUrl: String,
         scenes: [FcrBoardScene]?,
         convert: Bool?) {
        self.resourceName = resourceName
        self.resourceUuid = resourceUuid
        self.resourceUrl = resourceUrl
        self.scenes = scenes
        self.convert = convert
    }
}

struct FcrBoardScene: Convertable {
    var name: String
    var ppt: FcrBoardWhitePptPage
}

struct FcrBoardWhitePptPage: Convertable {
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
}

// MARK: - step
enum FcrBoardStepChangeType: Convertable {
    case pre(Int)
    case next(Int)
    case undoAble(Bool)
    case redoAble(Bool)
    
    private enum CodingKeys: CodingKey {
        case pre
        case next
        case undoAble
        case redoAble
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode(Int.self,
                                         forKey: .pre) {
            self = .pre(x)
        } else if let x = try? container.decode(Int.self,
                                                forKey: .next) {
            self = .next(x)
        } else if let x = try? container.decode(Bool.self,
                                                forKey: .undoAble) {
            self = .undoAble(x)
        } else if let x = try? container.decode(Bool.self,
                                                forKey: .redoAble) {
            self = .redoAble(x)
        } else {
            throw DecodingError.typeMismatch(FcrBoardStepChangeType.self,
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
        case .undoAble(let x):
            try container.encode(x,
                                 forKey: .undoAble)
        case .redoAble(let x):
            try container.encode(x,
                                 forKey: .redoAble)
        }
    }
}

// MARK: - aid
enum FcrBoardAidType: Int, Convertable {
    case clicker, area, laserPointer, eraser
    
    var wrapperType: FcrBoardToolType {
        switch self {
        case .clicker:      return .none
        case .area:         return .selector
        case .laserPointer: return .laserPointer
        case .eraser:       return .eraser
        }
    }
}

struct FcrBoardTextInfo: Convertable {
    var size: Int
    var color: Array<Int>
}

enum FcrBoardShapeType: Int, Convertable {
    case curve, straight, arrow, rectangle, triangle, rhombus, pentagram, ellipse
    
    var wrapperType: FcrBoardDrawShape {
        switch self {
        case .curve:        return .curve
        case .straight:     return .straight
        case .arrow:        return .arrow
        case .rectangle:    return .rectangle
        case .triangle:     return .triangle
        case .rhombus:      return .rhombus
        case .pentagram:    return .pentagram
        case .ellipse:      return .ellipse
        }
    }
}

struct FcrBoardShapeInfo: Convertable {
    var type: FcrBoardShapeType
    var width: Int
    var color: Array<Int>
}
    
enum FcrBoardAssistantType: Convertable {
    case tool(FcrBoardAidType)
    case text(FcrBoardTextInfo)
    case shape(FcrBoardShapeInfo)
    
    private enum CodingKeys: CodingKey {
        case tool
        case text
        case shape
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(FcrBoardAidType.self,
                                                    forKey: .tool) {
            self = .tool(value)
        } else if let value = try? container.decode(FcrBoardTextInfo.self,
                                                    forKey: .text) {
            self = .text(value)
        } else if let value = try? container.decode(FcrBoardShapeInfo.self,
                                                    forKey: .shape) {
            self = .shape(value)
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
        case .tool(let x):
            try container.encode(x,
                                 forKey: .tool)
        case .text(let x):
            try container.encode(x,
                                 forKey: .text)
        case .shape(let x):
            try container.encode(x,
                                 forKey: .shape)
        }
    }
}

// MARK: - props
struct FcrBooardConfigOfExtra: Decodable {
    var boardAppId: String
    var boardId: String
    var boardToken: String
    var boardRegion: String
}

struct FcrBooardUsageOfExtra: Decodable {
    var grantedUsers: [String: Bool]
}

// MARK: - Base
extension String {
    func toBoardWidgetSignal() -> FcrBoardInteractionSignal? {
        guard let dic = self.toDic(),
              let signal = dic.toObj(FcrBoardInteractionSignal.self) else {
                  return nil
              }
        
        return signal
    }
}

extension Array where Element == Int {
    var wrapperType: FcrColor? {
        guard self.count >= 3 else {
            return nil
        }
        return FcrColor(red: UInt8(self[0]),
                        green: UInt8(self[1]),
                        blue: UInt8(self[2]))
    }
}

extension Array where Element == FcrBoardScene {
    func toWrapper() -> [FcrBoardPage] {
        var pageArr = [FcrBoardPage]()
        for item in self {
            let page = FcrBoardPage(name: item.name,
                                    contentUrl: item.ppt.src,
                                    previewUrl: item.ppt.preview,
                                    contentWidth: item.ppt.width,
                                    contentHeight: item.ppt.height)
            
            pageArr.append(page)
        }
        
        return pageArr
    }
}
