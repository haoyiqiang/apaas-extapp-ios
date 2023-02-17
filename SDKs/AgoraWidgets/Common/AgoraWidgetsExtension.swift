//
//  AgoraWidgetsExtension.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import CommonCrypto
import Foundation
import AgoraWidget

struct AgoraWidgetRequestKeys {
    let agoraAppId: String
    let token: String
    let host: String
}

protocol Convertable: Codable {
    
}

extension Convertable {
    func toDictionary() -> [String: Any]? {
        var dic: [String: Any]?
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dic = try JSONSerialization.jsonObject(with: data,
                                                   options: .allowFragments) as? [String: Any]
        } catch {
            // TODO: error handle
            print(error)
        }
        
        return dic
    }
    
    public static func decode(_ dic: [String : Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dic),
              let data = try? JSONSerialization.data(withJSONObject: dic,
                                                     options: []),
              let model = try? JSONDecoder().decode(Self.self,
                                                    from: data)
        else {
            return nil
        }
        
        return model
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: JSONSerialization.WritingOptions.prettyPrinted)
        else {
            return nil
        }
        
        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    func toObject<T>(_ type: T.Type) -> T? where T : Decodable {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []),
              let model = try? JSONDecoder().decode(T.self,
                                                    from: data)
        else {
            return nil
        }
        
        return model
    }
}

extension Bundle {
    static func widgets_bundle() -> Bundle {
        return Bundle.agora_bundle("AgoraWidgets") ?? Bundle.main
    }
}

extension String {
    func toDictionary() -> [String: Any]? {
        guard let data = self.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data,
                                                             options: [.mutableContainers]),
              let dic = object as? [String: Any]
        else {
            return nil
        }
        
        return dic
    }
    
    func toRequestKeys() -> AgoraWidgetRequestKeys? {
        guard let dic = self.toDictionary(),
              let baseInfoDic = dic["keys"] as? [String: String],
              let appId = baseInfoDic["agoraAppId"] as? String,
              let token = baseInfoDic["token"] as? String,
              let host = baseInfoDic["host"] as? String
        else {
            return nil
        }
        
        return AgoraWidgetRequestKeys(agoraAppId: appId,
                                      token: token,
                                      host: host)
    }
    
    func toSyncTimestamp() -> Int64? {
        guard let dic = self.toDictionary(),
              let timestamp = dic["syncTimestamp"] as? Int64
        else {
            return nil
        }
        
        return timestamp
    }
    
    func agora_md5() -> String {
        let CC_MD5_DIGEST_LENGTH = 16
        
        guard self.count > 0 else {
            return ""
        }
        
        let cCharArray = self.cString(using: .utf8)
        var uint8Array = [UInt8](repeating: 0,
                                 count: CC_MD5_DIGEST_LENGTH)
        CC_MD5(cCharArray,
               CC_LONG(cCharArray!.count - 1),
               &uint8Array)
        let data = Data(bytes: &uint8Array,
                        count: CC_MD5_DIGEST_LENGTH)
        let base64Str = data.base64EncodedString()
        return base64Str
    }
    
    static func widgets_localized_replacing() -> String {
        return "{xxx}"
    }
    
    func widgets_localized() -> String {
        let widgetsBundle = Bundle.widgets_bundle()
        
        if let language = agora_ui_language,
           let languagePath = widgetsBundle.path(forResource: language,
                                                 ofType: "lproj"),
           let bundle = Bundle(path: languagePath) {
            
            return bundle.localizedString(forKey: self,
                                          value: nil,
                                          table: nil)
        } else {
            let text = widgetsBundle.localizedString(forKey: self,
                                                     value: nil,
                                                     table: nil)
            
            return text
        }
    }
}

extension UIImage {
    static func widgets_image(_ named: String) -> UIImage? {
        let resource = "AgoraWidgets"
        let bundle = Bundle.widgets_bundle()
        return UIImage(named: named,
                       in: bundle,
                       compatibleWith: nil)
    }
}

extension Double {
    /// will return 970B or 1.3K or 1.3M
    var toDataSizeUnitString: String {
        if self < 1024 {
            return "\(self.roundTo(places: 1))" + "B"
        }
        else if self < (1024 * 1024) {
            return "\((self/1024).roundTo(places: 1))" + "K"
        }
        else {
            return "\((self/(1024 * 1024)).roundTo(places: 1))" + "M"
        }
    }
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var intValue: Int64 {
        return Int64(self)
    }
}

extension Int64 {
    var formatStringHMS: String {
        let hour = self / 3600
        let minute = (self % 3600) / 60
        let second = self % 60
        return NSString(format: "%02ld:%02ld:%02ld", hour, minute, second) as String
    }
    
    var formatStringMS: String {
        let minute = (self % 3600) / 60
        let second = self % 60
        return NSString(format: "%02ld:%02ld", minute, second) as String
    }
}

extension TimeInterval {
    /// YY-MM-DD HH:mm:ss
    var formatString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        let date = Date(timeIntervalSince1970: self)
        return formatter.string(from: date)
    }
    
    var formatStringHMS: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let date = Date(timeIntervalSince1970: self)
        return formatter.string(from: date)
    }
}

extension AgoraBaseWidget {    
    var isTeacher: Bool {
        return info.localUserInfo.userRole == "teacher"
    }
}

extension NSError {
    static func create(_ error: Error?) -> Error {
        if let `error` = error {
            return error
        } else {
            return NSError.defaultError()
        }
    }
    
    static func defaultError() -> NSError {
        let error = NSError(domain: "",
                            code: -1)
        return error
    }
}

extension CALayer {
    func update(with shadow: FcrWidgetUIItemShadow) {
        shadowColor = shadow.color
        shadowOffset = shadow.offset
        shadowOpacity = shadow.opacity
        shadowRadius = shadow.radius
    }
}

func ValueTransform<Result>(value: Any?,
                            result: Result.Type) -> Result? {
    if let `value` = value {
        return (value as? Result)
    } else {
        return nil
    }
}

func ValueTransform<Result: RawRepresentable>(enumValue: Any?,
                                              result: Result.Type) -> Result? where Result.RawValue == Int {
    guard let intValue = ValueTransform(value: enumValue,
                                        result: Int.self) else {
        return nil
    }
    
    if let value = Result.init(rawValue: intValue) {
        return value
    } else {
        return nil
    }
}
