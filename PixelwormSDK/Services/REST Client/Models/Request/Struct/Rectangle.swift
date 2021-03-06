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
    
    public var x: Int
    public var y: Int
    public var width: Int
    public var height: Int
    
    // MARK: - Public Methods
    
    public var isEmpty: Bool {
        return width == 0 || height == 0
    }
    
    // MARK: - Operator Overloads
    
    static func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
        return lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.width == rhs.width &&
            lhs.height == rhs.height
    }
}
