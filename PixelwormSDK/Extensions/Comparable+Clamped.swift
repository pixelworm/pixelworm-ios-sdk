//
//  Comparable+Clamped.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 9.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/40868784

internal extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

internal extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
