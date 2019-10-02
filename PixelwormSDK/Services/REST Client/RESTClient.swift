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
    
    /// Private constructor.
    /// We don't want anyone to an create instance of `RESTClient`.
    private init() {
        
    }
    
    // MARK: - Constants
    
    private static let baseUrl = "https://api.pixelworm.io"
    
    // MARK: - Configurations
    
    internal var config: (apiKey: String, secretKey: String)!
    
    // MARK: - Requests
    
    private func doRequest<ResponseBodyType: Decodable>(
        _ endpoint: String,
        queryParameters: [String: String] = [:],
        method: HTTPMethod,
        bodySupplier: (() -> Data)? = nil,
        completionHandler: @escaping (Result<ResponseBodyType, Error>) -> ()
    ) {
        // Throw assertion error if config is not set
        assert(self.config != nil, "config must be set before calling doRequest")
        
        // Create URL Components
        var urlComponents = URLComponents(string: RESTClient.baseUrl + endpoint)!
        
        // Append query parameters to URL Components
        urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Create target URL
        let url = urlComponents.url!
        
        // Create request
        var request = URLRequest(url: url)
        
        // Configure request
        request.httpMethod = method.rawValue
        
        // Generate authorization base64 string
        let usernamePasswordBase64String = "\(self.config.apiKey):\(self.config.secretKey)".data(using: .utf8)!.base64EncodedString()
        
        // Set authorization
        request.setValue("Basic \(usernamePasswordBase64String)", forHTTPHeaderField: "Authorization")
        
        // Set body and content type if method is get and body supplier is set
        if method != .get, let bodySupplier = bodySupplier {
            // TODO: Maybe get content-type from supplier too?
            // Set content type
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Set body
            request.httpBody = bodySupplier()
        }
        
        // Put SDK type and version info to request header
        request.setValue(
            "ios-sdk",
            forHTTPHeaderField: "X-Requester-Type"
        )
        
        request.setValue(
            BundleManager.applicationVersion,
            forHTTPHeaderField: "X-Requester-Version"
        )
        
        // Create data task
        let task = URLSession.shared.dataTask(with: request) { result in
            switch (result) {
            case .success(let response, let data):
                if response.statusCode == 403 || response.statusCode == 404 {
                    DispatchQueue.main.async {
                        completionHandler(.failure(RESTClientError.invalidCredentials))
                    }
                    
                    return
                }
                
                if response.statusCode != 200 {
                    let message = String(data: data, encoding: .utf8)
                    
                    DispatchQueue.main.async {
                        completionHandler(.failure(RESTClientError.unexpectedStatusCode(statusCode: response.statusCode, message: message)))
                    }
                    
                    return
                }
                
                var deserializedResponse: ResponseBodyType!
                
                // Try to deserialize response
                do {
                    deserializedResponse = try JSONDecoder().decode(ResponseBodyType.self, from: data)
                } catch let error {
                    DispatchQueue.main.async {
                        completionHandler(.failure(RESTClientError.deserializationFailure(error: error)))
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(.success(deserializedResponse))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(RESTClientError.general(error: error)))
                }
            }
        }
        
        // Start task
        task.resume()
    }
    
    public func upsertScreen(_ request: UpsertScreenRequest, completionHandler: @escaping (Result<UpsertScreenResponse, Error>) -> Void) {
        doRequest("/sdk/upsert/screen", method: .put, bodySupplier: {
            return try! JSONEncoder().encode(request)
        }, completionHandler: completionHandler)
    }
    
    public func getScreenDetail(of uniqueId: String, completionHandler: @escaping (Result<GetScreenDetailResponse, Error>) -> Void) {
        doRequest("/sdk/screen-detail/\(uniqueId)", method: .get, completionHandler: completionHandler)
    }
}
