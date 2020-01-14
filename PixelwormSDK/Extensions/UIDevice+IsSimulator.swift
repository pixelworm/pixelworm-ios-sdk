//
//  UIDevice+IsSimulator.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 14.01.2020.
//  Copyright © 2020 Pixelworm. All rights reserved.
//

import UIKit

extension UIDevice {
    public static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}
