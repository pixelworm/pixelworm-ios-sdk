//
//  Rectangle.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal struct Rectangle: Encodable {
    // MARK: - Fields
    
    public var relativeX: Int
    public var relativeY: Int
    public var absoluteX: Int
    public var absoluteY: Int
    public var width: Int
    public var height: Int
}
