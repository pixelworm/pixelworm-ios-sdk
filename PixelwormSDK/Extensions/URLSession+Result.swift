//
//  URLSession+Result.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

// https://medium.com/@alfianlosari/building-simple-async-api-request-with-swift-5-result-type-alfian-losari-e92f4e9ab412

internal extension URLSession {
    func dataTask(with request: URLRequest, result: @escaping (Result<(response: HTTPURLResponse, data: Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                
                return
            }
            
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                
                result(.failure(error))
                
                return
            }
            
            result(.success((
                response: response as! HTTPURLResponse,
                data: data
            )))
        }
    }
}
