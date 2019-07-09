//
//  RESTClient.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal class RESTClient {
    // MARK: - Singleton Instance
    
    public static let shared = RESTClient()
    
    // MARK: - Constructors
    
    /**
     * Private constructor.
     * We don't want anyone to an create instance of `RESTClient`.
     */
    private init() {
        
    }
    
    // MARK: - Constants
    
    private static let BASE_URL = "https://api.pixelworm.io"
    
    // MARK: - Configurations
    
    internal var config: (apiKey: String, secretKey: String)!
    
    // MARK: - Requests
    
    private func doRequest<BodyType: Encodable, ResponseType: Decodable>(_ endpoint: String, method: HTTPMethod, body: BodyType?, completionHandler: @escaping (Result<ResponseType, Error>) -> ()) {
        // Throw assertion error if config is not set
        assert(self.config != nil, "config must be set before calling doRequest(_:method:body:completionHandler:)")
        
        // Create target URL
        let url = URL(string: RESTClient.BASE_URL + endpoint)!
        
        // Create request
        var request = URLRequest(url: url)
        
        // Configure request
        request.httpMethod = method.rawValue
        
        // Generate authorization base64 string
        let usernamePasswordBase64String = "\(self.config.apiKey):\(self.config.secretKey)".data(using: .utf8)!.base64EncodedString()
        
        // Set authorization
        request.setValue("Basic \(usernamePasswordBase64String)", forHTTPHeaderField: "Authorization")
        
        // Set body and content type if method is get and body is set
        if method != .get, let bodyUnwrapped = body {
            // Set content type
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Set body
            request.httpBody = try! JSONEncoder().encode(bodyUnwrapped)
        }
        
        // Put version info to request header
        request.setValue(
            BundleManager.applicationVersion,
            forHTTPHeaderField: "X-Requester-Version"
        )
        
        // Create data task
        let task = URLSession.shared.dataTask(with: request) { result in
            switch (result) {
            case .success(let response, let data):
                if response.statusCode == 403 || response.statusCode == 404 {
                    completionHandler(.failure(RESTClientError.invalidCredentials))
                    
                    return
                }
                
                var deserializedResponse: ResponseType!
                
                // Try to deserialize response
                do {
                    deserializedResponse = try JSONDecoder().decode(ResponseType.self, from: data)
                } catch let error {
                    completionHandler(.failure(RESTClientError.deserializationFailure(error: error)))
                    
                    return
                }
                
                completionHandler(.success(deserializedResponse))
            case .failure(let error):
                completionHandler(.failure(RESTClientError.general(error: error)))
            }
        }
        
        // Start task
        task.resume()
    }
    
    public func upsertScreen(_ request: UpsertScreenRequest, completionHandler: @escaping (Result<UpsertScreenResponse, Error>) -> ()) {
        doRequest("/sdk/applications/screens/upsert", method: .put, body: request, completionHandler: completionHandler)
    }
}
