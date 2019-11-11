//
//  UIWindow+ExportClosure.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 28.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension UIApplication {
    func exportClosure(with size: CGSize?, closure: () -> Void) {
        let window = self.keyWindow!
        
        var oldSize: CGSize? = nil
        
        // Check if size is present, resize layer if yes
        if let size = size {
            oldSize = window.frame.size
            
            window.frame.size = size
            
            // Update constraints to view will conform to our new size
            window.setNeedsUpdateConstraints()
        }
        
        // Size restorer
        // NOTE: Maybe don't use defer to make function simpler?
        defer {
            if let oldSize = oldSize {
                window.frame.size = oldSize
                
                // Update constra to view will conform to our new size
                window.setNeedsUpdateConstraints()
            }
        }
        
        // Call closure
        closure()
    }
}
