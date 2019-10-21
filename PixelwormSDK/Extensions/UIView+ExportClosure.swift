//
//  UIView+ExportClosure.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 28.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension UIView {
    func exportClosure(with size: CGSize?, closure: () -> Void) {
        var oldSize: CGSize? = nil
        
        // Check if size is present, resize layer if yes
        if let size = size {
            oldSize = self.layer.frame.size
            
            self.layer.frame.size = size
            
            // Update constraints to view will conform to our new size
            self.setNeedsUpdateConstraints()
        }
        
        self.setNeedsUpdateConstraints()
        
        // Size restorer
        // NOTE: Maybe don't use defer to make function simpler?
        defer {
            if let oldSize = oldSize {
                self.layer.frame.size = oldSize
                
                // Update constra to view will conform to our new size
                self.setNeedsUpdateConstraints()
            }
        }
        
        // Call closure
        closure()
    }
}
