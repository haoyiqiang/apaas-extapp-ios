//
//  AgoraWidgetLog.swift
//  AgoraWidgets
//
//  Created by Cavan on 2022/3/9.
//

import Foundation
import AgoraLog


protocol AgoraWidgetLogTube where Self: NSObject {
    var logger: AgoraWidgetLogger {set get}
    
    func log(content: String,
             extra: String?,
             type: AgoraLogType,
             funcName: String,
             line: Int)
}
 
extension AgoraWidgetLogTube {
    func log(content: String,
             extra: String? = nil,
             type: AgoraLogType,
             funcName: String = #function,
             line: Int = #line) {
        logger.log(content: content,
                   extra: extra,
                   type: type,
                   from: self.classForCoder,
                   funcName: funcName,
                   line: line)
    }
}

class AgoraWidgetLogger: NSObject {
    private let logger: AgoraLogger
    private let queue = DispatchQueue(label: "io.agora.widgets.log.thread")
    private var traceId: String
    var isPrintOnConsole: Bool = false
    
    init(widgetId: String) {
        let folderPath = GetWidgetLogFolder()
        
        logger = AgoraLogger(folderPath: folderPath,
                             filePrefix: widgetId,
                             maximumNumberOfFiles: 3)
        logger.setPrintOnConsoleType(.none)
        
        let timeStamp = "\(Date().timeIntervalSince1970.intValue)"
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        traceId = "\(timeStamp)\(deviceId)".agora_md5()
    }
    
    fileprivate func log(content: String,
                         extra: String?,
                         type: AgoraLogType,
                         from: AnyClass,
                         funcName: String = #function,
                         line: Int = #line) {
        queue.async { [weak self] in
            guard let `self` = self else {
                
                return
            }
            
            let classText = NSStringFromClass(from)
            
            var fileLog = "\(classText) \(line) : \(funcName) \(content)"
            
            if let `extra` = extra {
                fileLog.append(" \(extra)")
            }
            
            self.logger.log(fileLog,
                            type: type)
            
            guard self.isPrintOnConsole else {
                return
            }
            
            DispatchQueue.main.async {
                let separator = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                let timeRange: [Date.Range] = [.hour,
                                               .minute,
                                               .milliSecond]
                let currentDate = Date.currentDateString(with: timeRange,
                                                         separator: ":")
                
                var consoleArray = [separator,
                                    "TIME: \(currentDate)",
                                    "CLASS: \(classText)",
                                    "\(type.stringValue): \(content)",
                                    separator]
                
                if let ex = extra {
                    let index = consoleArray.count - 1
                    consoleArray.insert("EXTRA: \(ex)",
                                        at: index)
                }
                
                let consoleLog = consoleArray.joined(separator: "\n")
                
                print(consoleLog.utf8)
            }
        }
    }
}

extension Date {
    enum Range: String {
        case hour = "HH"
        case minute = "mm"
        case second = "ss"
        case milliSecond = "ss.SSS"
    }
    
    static func currentDateString(with range: [Range],
                                  separator: String? = nil) -> String {
        let array = range.map { (item) -> String in
            return item.rawValue
        }
        
        let formatter = DateFormatter()
        
        if let sep = separator {
            formatter.dateFormat = array.joined(separator: sep)
        } else {
            formatter.dateFormat = array.joined(separator: "")
        }
        
        return formatter.string(from: Date())
    }
}

extension AgoraLogType {
    var stringValue: String {
        switch self {
        case .debug:   return "DEBUG"
        case .warning: return "WARNING"
        case .info:    return "INFO"
        case .error:   return "ERROR"
        default:       return "INFO"
        }
    }
}

