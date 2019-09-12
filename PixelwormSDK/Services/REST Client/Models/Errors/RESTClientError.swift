//
//  RESTClientError.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal enum RESTClientError: Error {
    case unexpectedStatusCode(statusCode: Int, message: String?)
    case invalidCredentials
    case deserializationFailure(error: Error)
    case general(error: Error)
}
