//
//  UpsertScreenRequest.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 22.05.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import Foundation

internal struct UpsertScreenRequest: Encodable {
    // MARK: - Fields
    
    public var uniqueId: String
    public var name: String
    public var size: WidthHeight
    public var base64Image: String
    public var views: [View]
    public var constraints: [Constraint]
    
    // MARK: - Inner Structs
    
    internal struct View: Encodable {
        // MARK: - Fields
        
        public var uniqueId: String
        public var type: ViewType?
        public var name: String
        public var contentMode: ContentMode
        public var frame: Rectangle
        public var zIndex: Int
        public var base64Image: String?
        public var label: Label?
        public var image: Image?
        
        // MARK: - Constructors
        
        public init(
            uniqueId: String,
            name: String,
            contentMode: ContentMode,
            frame: Rectangle,
            zIndex: Int
        ) {
            self.uniqueId = uniqueId
            self.name = name
            self.contentMode = contentMode
            self.frame = frame
            self.zIndex = zIndex
        }
        
        // MARK: - Inner Types
        
        internal enum ViewType: String, Encodable {
            case label = "LABEL"
            case image = "IMAGE"
        }
        
        internal enum ContentMode: String, Encodable {
            case scaleToFill = "SCALE_TO_FILL"
            case scaleAspectFit = "SCALE_ASPECT_FIT"
            case scaleAspectFill = "SCALE_ASPECT_FILL"
            case redraw = "REDRAW"
            case center = "CENTER"
            case top = "TOP"
            case bottom = "BOTTOM"
            case left = "LEFT"
            case right = "RIGHT"
            case topLeft = "TOP_LEFT"
            case topRight = "TOP_RIGHT"
            case bottomLeft = "BOTTOM_LEFT"
            case bottomRight = "BOTTOM_RIGHT"
        }
        
        internal struct Label: Encodable {
            // MARK: - Fields
            
            public var text: String
            public var font: Font
            
            // MARK: - Inner Types
            
            internal struct Font: Encodable {
                // MARK: - Fields
                
                public var family: String
                public var size: Int
                public var color: Color
                public var isBold: Bool
                public var isItalic: Bool
                public var isUnderlined: Bool
                public var isStrikethrough: Bool
                
                // MARK: - Inner Types
                
                internal struct Color: Encodable {
                    // MARK: - Fields
                    
                    public var red: Int
                    public var green: Int
                    public var blue: Int
                    public var alpha: Int
                    
                    // MARK: - Public Methods
                    
                    public static func from(nativeColor: CIColor) -> Color {
                        return Color(
                            red: Int(nativeColor.red * 255),
                            green: Int(nativeColor.green * 255),
                            blue: Int(nativeColor.blue * 255),
                            alpha: Int(nativeColor.alpha * 255)
                        )
                    }
                }
            }
        }
        
        internal struct Image: Encodable {
            // MARK: - Fields
            
            public var isPresent: Bool
            public var base64Image: String?
        }
    }
    
    internal struct Constraint: Encodable {
        // MARK: - Fields
        
        public var viewUniqueId: String
        public var attribute: Attribute
        public var value: Double
        public var hasTarget: Bool
        public var targetViewUniqueId: String?
        public var targetAttribute: Attribute?
        
        // MARK: - Inner Types
        
        internal enum Attribute: String, Encodable {
            case top = "TOP"
            case bottom = "BOTTOM"
            case leading = "LEADING"
            case trailing = "TRAILING"
        }
    }
}
