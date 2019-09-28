//
//  UpsertScreenResponse.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal struct UpsertScreenResponse: Decodable {
    // MARK: - Fields
    
    public let type: ResponseType
    public let expectedWidth: Int!
    public let supportedDeviceNames: Set<String>?
    
    // MARK: - Inner Types
    
    public enum ResponseType: String, Decodable {
        case processedDirectly = "PROCESSED_DIRECTLY"
        case enqueued = "ENQUEUED"
        case widthMismatch = "WIDTH_MISMATCH"
    }
}
