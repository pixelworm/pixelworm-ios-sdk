//
//  PixelwormError.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

public enum PixelwormError: Error {
    case alreadyAttached
    case alreadyDetached
    case apiKeyIsNotValid
    case secretKeyIsNotValid
}
