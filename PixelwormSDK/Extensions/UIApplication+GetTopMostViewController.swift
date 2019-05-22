//
//  UIApplication+GetTopMostViewController.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension UIApplication {
    class func getTopMostViewController(
        parent: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    ) -> UIViewController? {
        // Go deeper if type is `UINavigationController`
        if let navigationController = parent as? UINavigationController {
            return getTopMostViewController(parent: navigationController.visibleViewController)
        }
        
        // Go deeper if type is `UITabBarController`
        if let tabBarController = parent as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return getTopMostViewController(parent: selectedViewController)
            }
        }
        
        // Go deeper if view controller has presenting view controller in it
        if let presentedViewController = parent?.presentedViewController {
            return getTopMostViewController(parent: presentedViewController)
        }
        
        // Return current view controller
        return parent
    }
}
