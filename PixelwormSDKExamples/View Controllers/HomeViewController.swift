//
//  HomeViewController.swift
//  PixelwormSDKExamples
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit

internal class HomeViewController: UIViewController {
    // MARK: - Actions
    
    @IBAction func helloButtonTapped(_ sender: UIButton) {
        // Create alert controller
        let alertController = UIAlertController(title: "... world!", message: "Hello world!", preferredStyle: .alert)
        
        // Add dismiss action
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
            alertController.dismiss(animated: true)
        })
        
        // Show alert
        self.present(alertController, animated: true)
    }
}
