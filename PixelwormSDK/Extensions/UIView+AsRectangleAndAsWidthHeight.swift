//
//  UIView+AsRectangleAndAsWidthHeight.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal extension UIView {
    func asAbsoluteRectangle(frameRect: Rectangle? = nil) -> Rectangle {
        let absolutePosition = self.superview?.convert(self.frame.origin, to: nil) ?? self.frame.origin
        
        var rectangle = Rectangle(
            x: Int(absolutePosition.x),
            y: Int(absolutePosition.y),
            width: Int(self.frame.width),
            height: Int(self.frame.height)
        )
        
        if let frameRect = frameRect {
            if rectangle.x < 0 {
                rectangle.width += rectangle.x
                rectangle.x = 0
            }

            if rectangle.y < 0 {
                rectangle.height += rectangle.y
                rectangle.y = 0
            }

            if rectangle.x + rectangle.width >= frameRect.width {
               rectangle.width = frameRect.width - rectangle.x
            }

            if rectangle.y + rectangle.height >= frameRect.height {
               rectangle.height = frameRect.height - rectangle.y
            }
        }
        
        return rectangle
    }
    
    func asWidthHeight() -> WidthHeight {
        return WidthHeight(
            width: Int(self.frame.width),
            height: Int(self.frame.height)
        )
    }
}
