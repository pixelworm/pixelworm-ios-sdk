//
//  Exporter.swift
//  PixelwormSDK
//
//  Created by Doğu Emre DEMİRÇİVİ on 21.10.2019.
//  Copyright © 2019 Pixelworm. All rights reserved.
//

import UIKit
import AVFoundation

internal class Exporter {
    private var visibleViewController: UIViewController
    public private(set) var viewControllerName: String
    private var frameRectangle: Rectangle!
    private var absoluteImageFrames: [UIImageView: (absoluteFrame: Rectangle, absoluteInnerImageFrame: Rectangle)]
    
    public init() {
        self.visibleViewController = UIApplication.visibleViewController!
        self.viewControllerName = UIApplication.getTopMostViewController()!.className
        self.absoluteImageFrames = [:]
    }
    
    public var visibleView: UIView {
        return self.visibleViewController.view!
    }
    
    public var size: CGSize {
        return UIApplication.shared.keyWindow!.layer.frame.size
    }
    
    public func getUpsertScreenRequest(with size: CGSize) -> UpsertScreenRequest? {
        var request: UpsertScreenRequest! = nil
        
        UIApplication.shared.exportClosure(with: size) {
            self.frameRectangle = self.visibleView.asAbsoluteRectangle()
            
            request = UpsertScreenRequest(
                uniqueId: viewControllerName,
                // TODO: Get actual view controller name
                name: viewControllerName,
                size: WidthHeight(
                    width: Int(visibleView.layer.frame.width),
                    height: Int(visibleView.layer.frame.height)
                ),
                base64Image: visibleView.asImage().convertImageToBase64(),
                views: self.convertUIViewsToFlatViewDTOs([visibleView]),
                constraints: []
            )
            
            request.constraints = self.getConstraints(of: [visibleView], and: request.views)
            
            updateImageViewConstraints(&request)
            
            // Reset type counter
            TypeCounter.reset()
            
            // Don't upsert if hash is not different from previous one
            if !HashHolder.isDifferent(value: request) {
                request = nil
            } else {
                // Update hash value
                HashHolder.setLast(value: request)
            }
        }
        
        return request
    }
    
    private func updateImageViewConstraints(_ request: inout UpsertScreenRequest) {
        for (uiImageView, (absoluteFrame, absoluteInnerImageFrame)) in self.absoluteImageFrames {
            if absoluteFrame == absoluteInnerImageFrame { continue }
            
            for (viewIndex, view) in request.views.enumerated() {
                if view.uniqueId != uiImageView.identifier { continue }
                
                let xDifference = Double(absoluteFrame.x - absoluteInnerImageFrame.x)
                let yDifference = Double(absoluteFrame.y - absoluteInnerImageFrame.y)
                let widthDifference = Double(absoluteFrame.width - absoluteInnerImageFrame.width)
                let heightDifference = Double(absoluteFrame.height - absoluteInnerImageFrame.height)
                
                // Update view's frame
                var viewCopied = view
                
                viewCopied.frame = absoluteInnerImageFrame
                
                request.views[viewIndex] = viewCopied
                
                for (constraintIndex, constraint) in request.constraints.enumerated() {
                    if constraint.viewUniqueId != view.uniqueId { continue }
                    
                    var constraintCopied = constraint
                    
                    switch constraintCopied.attribute {
                    case .top:
                        constraintCopied.value += yDifference
                        
                    case .bottom:
                        constraintCopied.value += xDifference
                        
                    case .left:
                        constraintCopied.value += heightDifference
                        
                    case .right:
                        constraintCopied.value += widthDifference
                    }
                        
                    // Update constraint at index
                    request.constraints[constraintIndex] = constraintCopied
                }
            }
        }
    }
    
    private func convertUIViewsToFlatViewDTOs(_ uiViews: [UIView]) -> [UpsertScreenRequest.View] {
        var createdViews: [UpsertScreenRequest.View] = []
        
        for uiView in uiViews {
            if !isViewUpsertable(uiView) { continue }
            
            if !uiView.subviews.isEmpty {
                createdViews.append(contentsOf:
                    convertUIViewsToFlatViewDTOs(uiView.subviews)
                )
            }
            
            if let view = getView(from: uiView) {
                createdViews.append(view)
            }
        }
        
        return createdViews
    }
    
    private func isViewUpsertable(_ uiView: UIView) -> Bool {
        if uiView.isHidden { return false }
        else if uiView.asAbsoluteRectangle(frameRect: self.frameRectangle).isEmpty { return false }
        
        return true
    }
    
    private func getView(from uiView: UIView) -> UpsertScreenRequest.View? {
        var view = UpsertScreenRequest.View(
            uniqueId: uiView.identifier,
            // TODO: Get actual view name
            name: uiView.className,
            contentMode: getConvertedContentMode(uiView.contentMode)!,
            frame: uiView.asAbsoluteRectangle(frameRect: self.frameRectangle),
            zIndex: uiView.superview?.subviews.firstIndex(of: uiView) ?? 0
        )
        
        if let uiImageView = uiView as? UIImageView {
            view.type = .image
            view.image = getImage(from: uiImageView)
            
            if view.image!.isPresent {
                self.absoluteImageFrames[uiImageView] = (absoluteFrame: view.frame, absoluteInnerImageFrame: uiImageView.asAbsoluteInnerImageRectangle(frameRect: self.frameRectangle)!)
            }
        } else if let uiLabel = uiView as? UILabel {
            guard let label = getLabel(from: uiLabel) else { return nil }
            
            view.type = .label
            view.label = label
        } else if shouldExportViewAsImage(uiView) {
            view.type = .image
            view.image = UpsertScreenRequest.View.Image(isPresent: false, size: nil)
        } else {
            return nil
        }
        
        return view
    }
    
    private func getImage(from uiImageView: UIImageView) -> UpsertScreenRequest.View.Image {
        guard let image = uiImageView.image else {
            return UpsertScreenRequest.View.Image(isPresent: false, size: nil)
        }
        
        guard CGSize.zero != image.size else {
            return UpsertScreenRequest.View.Image(isPresent: false, size: nil)
        }

        return UpsertScreenRequest.View.Image(
            isPresent: true,
            size: WidthHeight(width: Int(image.size.width), height: Int(image.size.height))
        )
    }
    
    private func getLabel(from uiLabel: UILabel) -> UpsertScreenRequest.View.Label? {
        // Don't return label if it doesn't have any text in it
        if uiLabel.text == nil || uiLabel.text!.isEmpty {
            return nil
        }
        
        let rgbaColor = uiLabel.textColor.asRGBA() ?? (0, 0, 0, 0)
        
        // Get family name
        var familyName = uiLabel.font.familyName
        
        // Remove first dot if present
        if familyName.starts(with: ".") {
            familyName = String(familyName.dropFirst())
        }
        
        let font = UpsertScreenRequest.View.Label.Font(
            family: familyName,
            size: Int(uiLabel.font.pointSize),
            color: UpsertScreenRequest.View.Label.Font.Color.init(red: rgbaColor.red, green: rgbaColor.green, blue: rgbaColor.blue, alpha: rgbaColor.alpha),
            isBold: (uiLabel.font.fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0,
            isItalic: (uiLabel.font.fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0,
            isUnderlined: false /* TODO */,
            isStrikethrough: false /* TODO */
        )
        
        let label = UpsertScreenRequest.View.Label(
            text: uiLabel.text ?? "",
            font: font
        )
        
        return label
    }
    
    private func shouldExportViewAsImage(_ uiView: UIView) -> Bool {
        if uiView == self.visibleView {
            return true
        }
        
        if !uiView.isMember(of: UIView.self) &&
            // Table View
            !uiView.isKind(of: UITableViewCell.self) &&
            !(uiView.superview?.isKind(of: UITableViewCell.self) ?? true) &&
            // Collection View
            !uiView.isKind(of: UICollectionViewCell.self) &&
            !(uiView.superview?.isKind(of: UICollectionViewCell.self) ?? true) {
            return true
        }
        
        if (uiView.backgroundColor == nil ||
            uiView.backgroundColor == .clear ||
            uiView.backgroundColor == uiView.superview?.backgroundColor) &&
            (uiView.layer.shadowRadius == 0 || uiView.layer.shadowOpacity == 0) &&
            uiView.layer.borderWidth == 0 &&
            uiView.layer.cornerRadius == 0 {
            return false
        }
        
        return true
    }
    
    private func getConvertedContentMode(_ contentMode: UIView.ContentMode) -> UpsertScreenRequest.View.ContentMode? {
        let conversionDictionary: [UIView.ContentMode: UpsertScreenRequest.View.ContentMode] = [
            .scaleToFill: .scaleToFill,
            .scaleAspectFit: .scaleAspectFit,
            .scaleAspectFill: .scaleAspectFill,
            .redraw: .redraw,
            .center: .center,
            .top: .top,
            .bottom: .bottom,
            .left: .left,
            .right: .right,
            .topLeft: .topLeft,
            .topRight: .topRight,
            .bottomLeft: .bottomLeft,
            .bottomRight: .bottomRight
        ]
        
        return conversionDictionary[contentMode]
    }
    
    private func resolveConstraint(_ constraint: NSLayoutConstraint, viewDTOs: [UpsertScreenRequest.View]) -> NSLayoutConstraint? {
        if !checkIfConstraintIsValid(constraint) {
            return nil
        }
        
        if !(viewDTOs.contains { $0.uniqueId == constraint.firstView!.identifier }) {
            return nil
        }
        
        var constraints = [constraint]
        
        while true {
            let lastConstraint = constraints.last!
            
            let targetView = lastConstraint.secondView!
            
            if (viewDTOs.contains { $0.uniqueId == targetView.identifier }) {
                break
            }
            
            guard let nextPossibleConstraint = (targetView.constraints.filter {
                $0.firstAttribute == constraint.firstAttribute &&
                    $0.secondAttribute == constraint.secondAttribute &&
                    $0.firstView == targetView &&
                    checkIfConstraintIsValid($0)
            }.first) else {
                return nil
            }
            
            constraints.append(nextPossibleConstraint)
        }
        
        let lastConstraint = constraints.last!
        
        // Create sum of all constraints
        let constant = constraints.map { $0.constant }.reduce(0, +)
        
        return NSLayoutConstraint(
            item: constraint.firstView!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: lastConstraint.secondView,
            attribute: constraint.secondAttribute,
            multiplier: constraint.multiplier,
            constant: constant
        )
    }
    
    private func checkIfConstraintIsValid(_ constraint: NSLayoutConstraint) -> Bool {
        guard let firstView = constraint.firstView else {
            return false
        }
        
        guard let secondView = constraint.secondView else {
            return false
        }
        
        if secondView == firstView {
            return false
        }
        
        if !constraint.isActive {
            return false
        }
        
        if constraint.relation != .equal {
            return false
        }
        
        if constraint.multiplier != 1.0 {
            return false
        }
        
        if constraint.priority.rawValue != 1000.0 {
            return false
        }
        
        if !isAttributeSupported(constraint.firstAttribute)
            || !isAttributeSupported(constraint.secondAttribute) {
            return false
        }
        
        // Continue when any of two views is not upsertable
        if !isViewUpsertable(firstView)
            || !isViewUpsertable(secondView) {
            return false
        }
        
        return true
    }
    
    private func getConstraints(of views: [UIView], and viewDTOs: [UpsertScreenRequest.View]) -> [UpsertScreenRequest.Constraint] {
        var constraints: [UpsertScreenRequest.Constraint] = []
            
        // Get actual constraints
        constraints.append(contentsOf: getConstraintsExt(of: views, and: viewDTOs))
        
        // Get default constraints
        constraints.append(contentsOf: getConstraintsDefault(of: viewDTOs, constraints: constraints))
        
        return constraints
    }
    
    private func getConstraintsExt(of views: [UIView], and viewDTOs: [UpsertScreenRequest.View]) -> [UpsertScreenRequest.Constraint] {
        var constraintDTOs: [UpsertScreenRequest.Constraint] = []
        
        for view in views {
            if !view.subviews.isEmpty {
                constraintDTOs.append(contentsOf: getConstraintsExt(of: view.subviews, and: viewDTOs))
            }
            
            for constraint in view.constraints {
                guard let resolvedConstraint = resolveConstraint(constraint, viewDTOs: viewDTOs) else {
                    continue
                }
                
                let firstView = resolvedConstraint.firstView!
                let secondView = resolvedConstraint.secondView!
                
                let constraintDTO = UpsertScreenRequest.Constraint(
                    viewUniqueId: firstView.identifier,
                    attribute: getConvertedAttribute(resolvedConstraint.firstAttribute)!,
                    value: Double(resolvedConstraint.constant),
                    targetViewUniqueId: secondView.identifier,
                    targetAttribute: getConvertedAttribute(resolvedConstraint.secondAttribute)
                )
                
                let contains = constraintDTOs.contains {
                    $0.viewUniqueId == constraintDTO.viewUniqueId
                        && $0.attribute == constraintDTO.attribute
                        && $0.value == constraintDTO.value
                        && $0.targetViewUniqueId == constraintDTO.targetViewUniqueId
                        && $0.targetAttribute == constraintDTO.targetAttribute
                }
                
                // Continue if constraint already exists in list
                if contains {
                    continue
                }
                
                constraintDTOs.append(constraintDTO)
            }
        }
        
        return constraintDTOs
    }
    
    private func getConstraintsDefault(of viewDTOs: [UpsertScreenRequest.View], constraints actualConstraints: [UpsertScreenRequest.Constraint]) -> [UpsertScreenRequest.Constraint] {
        var constraints: [UpsertScreenRequest.Constraint] = []
        
        for viewDTO in viewDTOs {
            if !shouldAddDefaultConstraints(of: viewDTO, and: actualConstraints) {
                continue
            }
            
            // Create constraints
            let leftConstraint = UpsertScreenRequest.Constraint(
                viewUniqueId: viewDTO.uniqueId,
                attribute: .left,
                value: Double(viewDTO.frame.x),
                targetViewUniqueId: self.visibleView.identifier,
                targetAttribute: .left
            )
            
            let topConstraint = UpsertScreenRequest.Constraint(
                viewUniqueId: viewDTO.uniqueId,
                attribute: .top,
                value: Double(viewDTO.frame.y),
                targetViewUniqueId: self.visibleView.identifier,
                targetAttribute: .top
            )
            
            // Add constraints
            constraints.append(leftConstraint)
            constraints.append(topConstraint)
        }
        
        return constraints
    }
    
    private func shouldAddDefaultConstraints(of viewDTO: UpsertScreenRequest.View, and constraints: [UpsertScreenRequest.Constraint]) -> Bool {
        // Don't create looped constraints
        if viewDTO.uniqueId == self.visibleView.identifier {
            return false
        }
        
        let attributesThatMustNotExist: [UpsertScreenRequest.Constraint.Attribute] = [
            .top, .bottom, .left, .right
        ]
        
        return attributesThatMustNotExist.map { attributeThatMustNotExist in
            return constraints.contains { constraint in
                return constraint.viewUniqueId == viewDTO.uniqueId && constraint.attribute == attributeThatMustNotExist
            }
        }.allSatisfy { !$0 }
    }
    
    private func isAttributeSupported(_ attribute: NSLayoutConstraint.Attribute) -> Bool {
        return getConvertedAttribute(attribute) != nil
    }
    
    private func getConvertedAttribute(_ attribute: NSLayoutConstraint.Attribute) -> UpsertScreenRequest.Constraint.Attribute? {
        let conversionDictionary: [NSLayoutConstraint.Attribute: UpsertScreenRequest.Constraint.Attribute] = [
            .top: .top,
            .bottom: .bottom,
            // TODO: These are not right values
            .leading: .left,
            .trailing: .right
        ]
        
        return conversionDictionary[attribute]
    }
}
