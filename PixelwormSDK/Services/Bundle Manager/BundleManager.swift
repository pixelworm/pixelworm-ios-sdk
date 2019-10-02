//
//  BundleManager.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 1.07.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class BundleManager {
    /// Private constructor.
    /// We don't want anyone to an create instance of `BundleManager`.
    private init() {
        
    }
    
    public static var applicationVersion: String? {
        guard let infoDictionary = Bundle(for: Pixelworm.self).infoDictionary else {
            return nil
        }
        
        let version = infoDictionary["CFBundleShortVersionString"] as! String
        
        return version
    }
}
