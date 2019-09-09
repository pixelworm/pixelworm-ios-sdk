//
//  Device.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 9.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal struct Device {
    public var name: String
    public var resolution: Resolution
    
    internal struct Resolution {
        public var width: Int
        public var height: Int
    }
}
