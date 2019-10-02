//
//  BetterLock.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 2.10.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class ExtendedDefer {
    private let releaseCallback: () -> Void
    
    public init(releaseCallback: @escaping () -> Void) {
        self.releaseCallback = releaseCallback
    }

    deinit {
        self.releaseCallback()
    }
}
