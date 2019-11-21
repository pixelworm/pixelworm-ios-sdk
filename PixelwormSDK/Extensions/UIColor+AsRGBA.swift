//
//  UIColor+AsRGBA.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal extension UIColor {
    private static let allowedColorRange = (0...255)
    
    func asRGBA() -> (red: Int, green: Int, blue: Int, alpha: Int)? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0).clamped(to: UIColor.allowedColorRange)
            let iGreen = Int(fGreen * 255.0).clamped(to: UIColor.allowedColorRange)
            let iBlue = Int(fBlue * 255.0).clamped(to: UIColor.allowedColorRange)
            let iAlpha = Int(fAlpha * 255.0).clamped(to: UIColor.allowedColorRange)
            
            return (red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
        } else {
            // Return nil if we can't extract RGBA components
            return nil
        }
    }
}
