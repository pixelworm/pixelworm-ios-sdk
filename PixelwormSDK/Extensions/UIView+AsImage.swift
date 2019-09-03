//
//  UIView+AsImage.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension UIView {
    func asImage(withoutSubviews: Bool = false) -> UIImage {
        // TODO: Find a way to get image of view without its subviews
        var isHiddenMap = [UIView: Bool]()
        
        if withoutSubviews {
            for view in self.subviews {
                isHiddenMap[view] = view.isHidden
                
                view.isHidden = true
            }
        }
        
        defer {
            if withoutSubviews {
                for keyValuePair in isHiddenMap {
                    keyValuePair.key.isHidden = keyValuePair.value
                }
            }
        }
        
        // Create image context by image's frame size
        UIGraphicsBeginImageContext(self.frame.size)
        
        // Render to created context
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        // Get image from rendered context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Dispose context
        UIGraphicsEndImageContext()
        
        // TODO: Don't force it, handle its error
        return image!
    }
}
