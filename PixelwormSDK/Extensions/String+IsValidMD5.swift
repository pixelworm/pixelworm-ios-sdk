//
//  String+IsValidMD5.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal extension String {
    var isValidMD5: Bool {
        return self.matches("^[0-9a-fA-F]{32,32}$")
    }
}
