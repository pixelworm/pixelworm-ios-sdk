//
//  NSLayoutConstraint+ActualViews.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 4.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal extension NSLayoutConstraint {
    var firstView: UIView? {
        return getView(fromValue: self.firstItem)
    }
    
    var secondView: UIView? {
        return getView(fromValue: self.secondItem)
    }
    
    private func getView(fromValue value: AnyObject?) -> UIView? {
        // Check if item exists, otherwise return nil
        guard let item = value else { return nil }
        
        if let layoutGuide = (item as? UILayoutGuide) {
            return layoutGuide.owningView
        }
        
        return item as? UIView
    }
}
