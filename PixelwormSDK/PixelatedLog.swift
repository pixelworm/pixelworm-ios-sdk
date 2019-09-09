//
//  PixelatedLog.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 9.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal enum LogType {
    case fatal
    case warning
    case notify
    
    public var icon: String? {
        switch self {
        case .fatal:
            return "❗️"
        
        case .warning:
            return "⚠️"
            
        case .notify:
            return nil
        }
    }
}

internal func pprint(_ logType: LogType, _ content: String) {
    var log = "PX:: \(content)"
    
    if let icon = logType.icon {
        log = "[\(icon)] \(log)"
    }
    
    print(log)
}
