//
//  DeviceType.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 9.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class DeviceType {
    private static let devices = [
        Device(name: "iPhone XS Max", resolution: Device.Resolution(width: 414, height: 896)),
        Device(name: "iPhone XR", resolution: Device.Resolution(width: 414, height: 896)),
        Device(name: "iPhone X", resolution: Device.Resolution(width: 375, height: 812)),
        Device(name: "iPhone XS", resolution: Device.Resolution(width: 375, height: 812)),
        Device(name: "iPhone 6 Plus", resolution: Device.Resolution(width: 414, height: 736)),
        Device(name: "iPhone 6S Plus", resolution: Device.Resolution(width: 414, height: 736)),
        Device(name: "iPhone 7 Plus", resolution: Device.Resolution(width: 414, height: 736)),
        Device(name: "iPhone 8 Plus", resolution: Device.Resolution(width: 414, height: 736)),
        Device(name: "iPhone 6", resolution: Device.Resolution(width: 375, height: 667)),
        Device(name: "iPhone 6S", resolution: Device.Resolution(width: 375, height: 667)),
        Device(name: "iPhone 7", resolution: Device.Resolution(width: 375, height: 667)),
        Device(name: "iPhone 8", resolution: Device.Resolution(width: 375, height: 667)),
        Device(name: "iPhone 5", resolution: Device.Resolution(width: 320, height: 568)),
        Device(name: "iPhone 5S", resolution: Device.Resolution(width: 320, height: 568)),
        Device(name: "iPhone 5C", resolution: Device.Resolution(width: 320, height: 568)),
        Device(name: "iPhone SE", resolution: Device.Resolution(width: 320, height: 568)),
        Device(name: "iPhone 4", resolution: Device.Resolution(width: 320, height: 480)),
        Device(name: "iPhone 4S", resolution: Device.Resolution(width: 320, height: 480)),
        Device(name: "iPhone(Legacy)", resolution: Device.Resolution(width: 320, height: 480)),
        Device(name: "iPod Touch", resolution: Device.Resolution(width: 320, height: 480)),
        Device(name: "iPad Pro 12.9 1st", resolution: Device.Resolution(width: 1024, height: 1366)),
        Device(name: "iPad Pro 12.9 2nd", resolution: Device.Resolution(width: 1024, height: 1366)),
        Device(name: "iPad Pro 10.5", resolution: Device.Resolution(width: 834, height: 1112)),
        Device(name: "iPad 3", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad 4", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Air", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Air 2", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Pro 9.7-inch", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad 5th", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad 6th", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad 1st", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad 2nd", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Mini Retina 2nd", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Mini Retina 3rd", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Mini Retina 4th", resolution: Device.Resolution(width: 768, height: 1024)),
        Device(name: "iPad Mini 1st", resolution: Device.Resolution(width: 768, height: 1024))
    ]
    
    public static func getDevices(forWidth width: Int, isLandscape: Bool, _ maxCount: Int? = nil) -> [Device] {
        var filteredDevices = devices.filter {
            if isLandscape {
                return $0.resolution.height == width
            }
            
            return $0.resolution.width == width
        }
        
        if let maxCount = maxCount {
            filteredDevices = Array(filteredDevices.prefix(maxCount))
        }
        
        return filteredDevices
    }
}
