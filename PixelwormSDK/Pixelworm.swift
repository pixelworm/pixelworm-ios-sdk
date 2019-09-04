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
    
    // MARK: - Constructors
    
    /**
     * Private constructor.
     * We don't want anyone to an create instance of `Pixelworm`.
     */
    private init() {
        
    }
    
    // MARK: - Fields
    
    private var isAttached = false
    private var timer: Timer!
    
    // MARK: - Public Methods
    
    public static func attach(withApiKey apiKey: String, andSecretKey secretKey: String) throws {
        if Pixelworm.shared.isAttached {
            throw PixelwormError.alreadyAttached
        }
        
        if !apiKey.isValidMD5 {
            throw PixelwormError.apiKeyIsNotValid
        }
        
        if !secretKey.isValidMD5 {
            throw PixelwormError.secretKeyIsNotValid
        }
        
        Pixelworm.shared.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: Pixelworm.shared.callback)
        
        RESTClient.shared.config = (apiKey: apiKey, secretKey: secretKey)
        
        Pixelworm.shared.isAttached = true
    }
    
    public static func detach() throws {
        if !Pixelworm.shared.isAttached {
            throw PixelwormError.alreadyDetached
        }

        Pixelworm.shared.timer.invalidate()
        Pixelworm.shared.timer = nil
        
        HashHolder.reset()
        TypeCounter.reset()
        
        RESTClient.shared.config = nil
        
        Pixelworm.shared.isAttached = false
    }
    
    // MARK: - Private Methods
    
    private func callback(_ : Timer) {
        upsertScreenIfChanged()
    }

    private func upsertScreenIfChanged() {
        let activeViewController = UIApplication.rootViewController!
        
        let topMostViewControllerName = UIApplication.getTopMostViewController()?.className ?? "FailedToGetViewControllerName"
        
        let activeView = activeViewController.view!
        
        var request = UpsertScreenRequest(
            uniqueId: topMostViewControllerName,
            // TODO: Get actual view controller name
            name: topMostViewControllerName,
            size: WidthHeight(width: Int(activeView.frame.width), height: Int(activeView.frame.height)),
            base64Image: activeView.asImage().convertImageToBase64(),
            views: convertUIViewsToFlatViewDTOs([activeView]),
            constraints: []
        )
        
        request.constraints = getConstraints(ofViews: [activeView], andViewDTOs: request.views)
        
        // Reset type counter
        TypeCounter.reset()
        
        // Don't upsert if hash is not different from previous one
        if !HashHolder.isDifferent(value: request) {
            return
        }
        
        // Update hash value
        HashHolder.setLast(value: request)
 
        RESTClient.shared.upsertScreen(request) { result in
            switch(result) {
            case .success(let response):
                switch(response.type) {
                case .enqueued:
                    print("Successfully enqueued \(request.name)! Please re-map your screen in Pixelworm Application in order to see newly exported screen.")
                    
                case .processedDirectly:
                    print("Successfully exported \(request.name)! Please check Screens page in Pixelworm Application in order to see newly exported screen.")
                    
                case .widthMismatch:
                    print("Failed to export \(request.name). Please make sure your simulator's screen width equals to Pixelworm Application's width setting.")
                }
                
            case .failure(let error):
                print("Failed to upload screen information to Pixelworm servers, error: \(error)")
            }
        }
    }
    
    private func convertUIViewsToFlatViewDTOs(_ uiViews: [UIView]) -> [UpsertScreenRequest.View] {
        var createdViews = [UpsertScreenRequest.View]()
        
        for uiView in uiViews {
            if !isViewUpsertable(uiView) { continue }
            
            if !uiView.subviews.isEmpty {
                createdViews.append(contentsOf: convertUIViewsToFlatViewDTOs(uiView.subviews))
            }
            
            if let view = getView(fromUIView: uiView) {
                createdViews.append(view)
            }
        }
        
        return createdViews
    }
    
    private func isViewUpsertable(_ view: UIView) -> Bool {
        if view.isHidden { return false }
        else if view.frame.isEmpty  { return false }
        
        return true
    }
    
    private func getView(fromUIView uiView: UIView) -> UpsertScreenRequest.View? {
        var view = UpsertScreenRequest.View(
            uniqueId: uiView.identifier,
            // TODO: Get actual view name
            name: uiView.className,
            contentMode: getConvertedContentMode(uiView.contentMode)!,
            frame: uiView.asRectangle(),
            zIndex: uiView.superview!.subviews.firstIndex(of: uiView)!
        )
        
        if let uiImageView = uiView as? UIImageView {
            view.type = .image
            view.base64Image = uiView.asImage().convertImageToBase64()
            view.image = getImage(fromUIImageView: uiImageView)
        } else if let uiLabel = uiView as? UILabel {
            view.type = .label
            view.base64Image = uiView.asImage().convertImageToBase64()
            view.label = getLabel(fromUILabel: uiLabel)
        } else if let imageBase64 = getImageBase64IfImportant(fromUIView: uiView) {
            view.type = .image
            view.base64Image = imageBase64
            view.image = UpsertScreenRequest.View.Image(isPresent: false, base64Image: nil)
        } else {
            return nil
        }
        
        return view
    }
    
    private func getImage(fromUIImageView uiImageView: UIImageView) -> UpsertScreenRequest.View.Image {
        return UpsertScreenRequest.View.Image(
            isPresent: uiImageView.image != nil,
            base64Image: uiImageView.image?.convertImageToBase64()
        )
    }
    
    private func getLabel(fromUILabel uiLabel: UILabel) -> UpsertScreenRequest.View.Label {
        let rgbaColor = uiLabel.textColor.asRGBA() ?? (0, 0, 0, 0)
        
        let font = UpsertScreenRequest.View.Label.Font(
            family: uiLabel.font.familyName,
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
    
    private func getImageBase64IfImportant(fromUIView uiView: UIView) -> String? {
        if uiView.isKind(of: UISwitch.self) {
            return uiView.asImage().convertImageToBase64()
        }
        
        if (uiView.backgroundColor == nil ||
            uiView.backgroundColor == .clear ||
            uiView.backgroundColor == uiView.superview?.backgroundColor) &&
            uiView.layer.shadowRadius == 0 &&
            uiView.layer.borderWidth == 0 {
            return nil
        }
        
        return uiView.asImage(withoutSubviews: true).convertImageToBase64()
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
    
    private func getConstraints(ofViews views: [UIView], andViewDTOs viewDTOs: [UpsertScreenRequest.View]) -> [UpsertScreenRequest.Constraint] {
        var constraintDTOs = [UpsertScreenRequest.Constraint]()
        
        for view in views {
            constraintDTOs.append(contentsOf: getConstraints(ofViews: view.subviews, andViewDTOs: viewDTOs))
            
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
                    hasTarget: true,
                    targetViewUniqueId: secondView.identifier,
                    targetAttribute: getConvertedAttribute(resolvedConstraint.secondAttribute)
                )
                
                let contains = constraintDTOs.contains {
                    $0.viewUniqueId == constraintDTO.viewUniqueId
                        && $0.attribute == constraintDTO.attribute
                        && $0.value == constraintDTO.value
                        && $0.hasTarget == constraintDTO.hasTarget
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
    
    private func isAttributeSupported(_ attribute: NSLayoutConstraint.Attribute) -> Bool {
        let supportedConstraints: [NSLayoutConstraint.Attribute] = [
            .left, .right, .top, .bottom, .leading, .trailing
        ]
        
        return supportedConstraints.contains(attribute)
    }
    
    private func getConvertedAttribute(_ attribute: NSLayoutConstraint.Attribute) -> UpsertScreenRequest.Constraint.Attribute? {
        let conversionDictionary: [NSLayoutConstraint.Attribute: UpsertScreenRequest.Constraint.Attribute] = [
            .left: .leading,
            .right: .trailing,
            .top: .top,
            .bottom: .bottom,
            .leading: .leading,
            .trailing: .trailing
        ]
        
        return conversionDictionary[attribute]
    }
}
