//
//  UIImageView+GetInnerImageBounds.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 24.12.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation
import AVFoundation

extension UIImageView {
    internal func asAbsoluteInnerImageRectangle(frameRect: Rectangle? = nil) -> Rectangle? {
        guard let image = self.image else { return nil }

        guard CGSize.zero != image.size else { return nil }

        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)

        let frame = self.asAbsoluteRectangle(frameRect: frameRect)

        return Rectangle(
            x: frame.x + Int(imageRect.minX),
            y: frame.y + Int(imageRect.minY),
            width: Int(imageRect.width),
            height: Int(imageRect.height)
        )
    }
}
