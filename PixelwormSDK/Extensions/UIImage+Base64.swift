//
//  File.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal extension UIImage {
    //
    // Convert String to base64
    //
    func convertImageToBase64() -> String {
        let imageData = self.pngData()!
        
        return imageData.base64EncodedString(options: [])
    }
    
    //
    // Convert base64 to String
    //
    convenience init(fromBase64 base64: String) {
        let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)!
        
        self.init(data: imageData)!
    }
}
