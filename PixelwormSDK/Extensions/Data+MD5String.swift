//
//  Data+MD5String.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation
import CommonCrypto

internal extension Data {
    var md5String: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        var digestHex = ""
        
        // TODO: Stop using deprecated method
        self.withUnsafeBytes { (bytes: UnsafePointer<CChar>) -> Void in
            CC_MD5(bytes, CC_LONG(self.count), &digest)
            
            for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                digestHex += String(format: "%02x", digest[index])
            }
        }
        
        return digestHex
    }
}
