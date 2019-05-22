//
//  NSObject+ClassName.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
    
    var identifier: String {
        let pointer = Unmanaged.passUnretained(self).toOpaque()
        let address = Int(bitPattern: pointer)
        
        return "\(className)-\(address)"
    }
}
