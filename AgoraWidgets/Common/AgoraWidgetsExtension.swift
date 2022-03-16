//
//  AgoraWidgetsExtension.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import CommonCrypto
import Foundation

struct AgoraAppBaseInfo {
    let agoraAppId: String
    let token: String
    let host: String
}

protocol Convertable: Codable {
    
}

extension Convertable {
    func toDictionary() -> Dictionary<String, Any>? {
        var dic: Dictionary<String,Any>?
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dic = try JSONSerialization.jsonObject(with: data,
                                                   options: .allowFragments) as? Dictionary<String, Any>
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
                                                    from: data) else {
                  return nil
              }
        return model
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        
        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    func toObj<T>(_ type: T.Type) -> T? where T : Decodable {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []),
              let model = try? JSONDecoder().decode(T.self,
                                                    from: data) else {
                  return nil
              }
        return model
    }
}

extension String {
    func toDic() -> [String: Any]? {
        guard let data = self.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data,
                                                             options: [.mutableContainers]),
              let dic = object as? [String: Any] else {
                  return nil
              }
        
        return dic
    }
    
    func toArr() -> [Any]? {
        guard let data = self.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data,
                                                             options: [.mutableContainers]),
              let arr = object as? [Any] else {
                  return nil
              }
        
        return arr
    }
    
    func toAppBaseInfo() -> AgoraAppBaseInfo? {
        guard let dic = self.toDic(),
              let baseInfoDic = dic["keys"] as? [String: String],
              let appId = baseInfoDic["agoraAppId"] as? String,
              let token = baseInfoDic["token"] as? String,
              let host = baseInfoDic["host"] as? String else {
                  return nil
              }
        return AgoraAppBaseInfo(agoraAppId: appId,
                                token: token,
                                host: host)
    }
    
    func toSyncTimestamp() -> Int64? {
        guard let dic = self.toDic(),
              let timestamp = dic["syncTimestamp"] as? Int64 else {
            return nil
        }
        
        return timestamp
    }
    
    func ag_widget_localized() -> String {
        let resource = "AgoraWidgets"
        return self.ag_localizedIn(resource)
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
    
    static func ag_localized_replacing() -> String {
        return "{xxx}"
    }
}

extension UIImage {
    static func ag_imageName(_ name: String) -> UIImage? {
        let resource = "AgoraWidgets"
        let bundle = Bundle.ag_compentsBundleNamed(resource)
        return UIImage.init(named: name,
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

// MARK: - resource
public func GetWidgetImage(object: NSObject,
                           _ name: String) -> UIImage? {
    let resource = "AgoraWidgets"
    return UIImage.agora_bundle(object: object,
                                resource: resource,
                                name: name)
}

public func GetWidgetLocalizableString(object: NSObject,
                                       key: String) -> String {
    let resource = "AgoraWidgets"
    return String.agora_localized_string(key,
                                         object: object,
                                         resource: resource)
}

public func GetWidgetLogFolder() -> String {
    let cachesFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                           .userDomainMask,
                                                           true)[0]
    let folder = cachesFolder.appending("/AgoraLog")
    let manager = FileManager.default
    
    if !manager.fileExists(atPath: folder,
                           isDirectory: nil) {
        try? manager.createDirectory(atPath: folder,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
    }
    return folder
}

extension AgoraBaseWidget {
    var isTeacher: Bool {
        return info.localUserInfo.userRole == "teacher"
    }
}
