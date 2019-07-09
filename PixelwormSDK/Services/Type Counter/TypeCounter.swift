//
//  TypeCounter.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class TypeCounter {
    private static var types = [String: Int]()
    
    /**
     * Private constructor.
     * We don't want anyone to an create instance of `TypeCounter`.
     */
    private init() {
        
    }
    
    public static func reset() {
        types.removeAll()
    }
    
    public static func getNextCount<T: NSObject>(value: T) -> Int {
        let key = value.className
        
        if types[key] == nil {
            types[key] = 0
        } else {
            types[key]! += 1
        }
        
        return types[key]!
    }
}
