//
//  UIView+AsRectangleAndAsWidthHeight.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension UIView {
    func asRectangle() -> Rectangle {
        let absolutePosition = self.superview?.convert(self.frame.origin, to: nil) ?? self.frame.origin
        
        return Rectangle(
            x: Int(absolutePosition.x),
            y: Int(absolutePosition.y),
            width: Int(self.frame.width),
            height: Int(self.frame.height)
        )
    }
    
    func asWidthHeight() -> WidthHeight {
        return WidthHeight(
            width: Int(self.frame.width),
            height: Int(self.frame.height)
        )
    }
}
