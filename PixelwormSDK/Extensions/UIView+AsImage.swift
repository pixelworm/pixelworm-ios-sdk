//
//  UIView+AsImage.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal extension UIView {
    func asImage() -> UIImage {
        // Create image context by image's frame size
        UIGraphicsBeginImageContext(self.layer.frame.size)
        
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
