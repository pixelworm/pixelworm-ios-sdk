//
//  GetScreenDetailResponse.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 27.09.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal struct GetScreenDetailResponse: Decodable {
    // MARK: - Fields
    
    public let type: ResponseType
    public let height: Int?
    
    // MARK: - Inner Types
    
    public enum ResponseType: String, Decodable {
        case mapped = "MAPPED"
        case notMapped = "NOT_MAPPED"
        case notExists = "NOT_EXISTS"
    }
}
