//
//  HashHolder.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class HashHolder {
    private static var lastData: Data?
    
    /// Private constructor.
    /// We don't want anyone to an create instance of `HashHolder`.
    private init() {
        
    }
    
    public static func isDifferent<T: Encodable>(value: T) -> Bool {
        let data = try! JSONEncoder().encode(value)
        
        guard let lastDataUnwrapped = lastData else {
            lastData = data
            
            return true
        }
        
        return !lastDataUnwrapped.elementsEqual(data)
    }
    
    public static func setLast<T: Encodable>(value: T) {
        lastData = try! JSONEncoder().encode(value)
    }
    
    public static func reset() {
        lastData = nil
    }
}
