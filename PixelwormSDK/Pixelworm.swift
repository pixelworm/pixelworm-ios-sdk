//
//  Pixelworm.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

public class Pixelworm {
    // MARK: - Singleton Instance
    
    private static let shared = Pixelworm()
    
    // MARK: - Constants
    
    private static let exportTimeInterval: TimeInterval = 5
    
    // MARK: - Constructors
    
    /// Private constructor.
    /// We don't want anyone to an create instance of `Pixelworm`.
    private init() {
        
    }
    
    // MARK: - Fields
    
    private var isAttached = false
    private var timer: Timer!
    
    // MARK: - Public Methods
    
    public static func attach(apiKey: String, secretKey: String) {
        if !UIDevice.isSimulator {
            pprint(
                .warning,
                "Your application must working under a simulator in order to " +
                "export your views to Pixelworm servers. Cancelled attaching."
            )
        
            return
        }
        
        if Pixelworm.shared.isAttached {
            pprint(.warning, "Pixelworm is already attached.")
            
            return
        }
        
        if !apiKey.isValidMD5 {
            pprint(.notify, "Your API Key is not valid.")
            
            return
        }
        
        if !secretKey.isValidMD5 {
            pprint(.notify, "Your Secret Key is invalid.")
            
            return
        }
        
        Pixelworm.shared.startTimer()
        
        RESTClient.shared.config = (apiKey: apiKey, secretKey: secretKey)
        
        Pixelworm.shared.isAttached = true
    }
    
    public static func detach() {
        if !UIDevice.isSimulator {
            pprint(
                .warning,
                "Your application must working under a simulator in order to " +
                "export your views to Pixelworm servers. Cancelled detaching."
            )

            return
        }

        if !Pixelworm.shared.isAttached {
            pprint(.warning, "Pixelworm is already detached.")
            
            return
        }
        
        Pixelworm.shared.stopTimer()
        
        HashHolder.reset()
        TypeCounter.reset()
        
        RESTClient.shared.config = nil
        
        Pixelworm.shared.isAttached = false
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        Pixelworm.shared.timer = Timer.scheduledTimer(
            withTimeInterval: Pixelworm.exportTimeInterval,
            repeats: true,
            block: Pixelworm.shared.callback
        )
    }
    
    private func stopTimer() {
        Pixelworm.shared.timer?.invalidate()
        Pixelworm.shared.timer = nil
    }
    
    private func callback(_ : Timer) {
        stopTimer()
        
        upsertScreenIfChanged() {
            // Don't start timer again if we're detached
            if !Pixelworm.shared.isAttached {
                return
            }
            
            self.startTimer()
        }
    }
    
    private func upsertScreenIfChanged(_ completionHandler: @escaping () -> Void) {
        let extendedDefer = ExtendedDefer {
            completionHandler()
        }
        
        let exporter = Exporter()
        
        RESTClient.shared.getScreenDetail(of: exporter.viewControllerName) { [extendedDefer] result in
            var size = exporter.size
            
            switch result {
            case .success(let response):
                switch response.type {
                case .mapped:
                    size.height = CGFloat(response.height!)
                    
                default:
                    break
                }
                
            case .failure(let error):
                pprint(.fatal, "Failed to get screen detail from Pixelworm servers, error: \(error).")
                
                return
            }
            
            guard let request = exporter.getUpsertScreenRequest(with: size) else {
                return
            }
            
            RESTClient.shared.upsertScreen(request) { [extendedDefer] result in
                // NOTE: Do not remove this line below
                // it keeps a strong reference to extended defer.
                _ = extendedDefer
                
                switch result {
                case .success(let response):
                    switch response.type {
                    case .enqueued:
                        pprint(.notify, "Successfully enqueued \(request.name)! Please re-map your screen in Pixelworm Application in order to see newly exported screen.")
                        
                    case .processedDirectly:
                        pprint(.notify, "Successfully exported \(request.name)! Please check Screens page in Pixelworm Application in order to see newly exported screen.")
                        
                    case .widthMismatch:
                        let deviceNames = response.supportedDeviceNames!.joined(separator: ", ")
                        
                        pprint(.warning, "Failed to export \(request.name). Your application doesn't support the width of your currently working device. Please consider using \(deviceNames).")
                    }
                    
                case .failure(let error):
                    pprint(.fatal, "Failed to upload screen information to Pixelworm servers, error: \(error).")
                }
            }
        }
    }
}
