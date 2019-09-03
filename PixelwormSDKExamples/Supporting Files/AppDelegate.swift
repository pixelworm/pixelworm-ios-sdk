//
//  AppDelegate.swift
//  PixelwormSDKExamples
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit
import PixelwormSDK

@UIApplicationMain
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        
        do {
            try Pixelworm.attach(withApiKey: "67f7ea3f334d46cf8b4d62778636fafb", andSecretKey: "339ce7a9bb5d48e9b58d63ea6a68742d")
        } catch let error {
            /*
             * TODO:
             * Handle errors as you wish.
             * Errors will be type of `PixelwormError`.
             */
            
            print("An error occurred while attaching Pixelworm, error: \(error)")
        }
        
        #endif

        return true
    }

    internal func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    internal func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    internal func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    internal func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    internal func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        #if DEBUG
        
        do {
            try Pixelworm.detach()
        } catch let error {
            /*
             * TODO:
             * Handle errors as you wish.
             * Errors will be type of `PixelwormError`.
             */
            
            print("An error occurred while detaching Pixelworm, error: \(error)")
        }
        
        #endif
    }
}
