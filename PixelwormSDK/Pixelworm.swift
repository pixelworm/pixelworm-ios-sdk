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
        let activeViewController = UIApplication.getTopMostViewController()
        
        let activeView = activeViewController!.view!
        
        var constraintDtos: [UpsertScreenRequest.Constraint] = []
        
        getConstraints(toList: &constraintDtos, ofView: activeView)
        
        let request = UpsertScreenRequest(
            uniqueId: activeViewController!.className,
            // TODO: Get actual view controller name
            name: activeViewController!.className,
            base64Image: activeViewController!.view.asImage().convertImageToBase64(),
            view: convertUIViewsToViews(views: [activeView])[0],
            constraints: constraintDtos
        )
        
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
    
    private func convertUIViewsToViews(views: [UIView]) -> [UpsertScreenRequest.View] {
        var createdViewDtos: [UpsertScreenRequest.View] = []
        
        for view in views {
            // Continue when view is not upsertable
            if !isViewUpsertable(view) { continue }
            
            // NOTE: zIndex accessors should be safer since some properties are optional we can screw up
            
            // TODO: Handle optionals, don't just force-unwrap them
            
            var viewDto = UpsertScreenRequest.View(
                uniqueId: view.identifier,
                // TODO: Get actual view name
                name: view.className,
                contentMode: getConvertedContentMode(view.contentMode)!,
                frame: view.asRectangle(),
                zIndex: view.superview!.subviews.firstIndex(of: view)!,
                base64Image: view.asImage().convertImageToBase64(),
                views: convertUIViewsToViews(views: view.subviews)
            )
            
            switch view {
            case let button as UIButton:
                var views: [UpsertScreenRequest.View] = []
                
                // Add button label to views only when label is present and label has text on it
                if let titleLabel = button.titleLabel,
                    !(titleLabel.text ?? "").isEmpty {
                    views.append(convertUIViewsToViews(views: [titleLabel])[0])
                }
                
                /*
                 * We're checking isEmpty property because imageView is being present
                 * while there is no image inside of it.
                 */
                if let backgroundImage = button.imageView,
                    !backgroundImage.frame.isEmpty {
                    views.append(convertUIViewsToViews(views: [backgroundImage])[0])
                }
                
                let buttonDto = UpsertScreenRequest.View.Button()
                
                viewDto.type = .button
                viewDto.button = buttonDto
                
            case let label as UILabel:
                let label = getLabel(fromUiLabel: label)
                
                viewDto.type = .label
                viewDto.label = label
                
            case let imageView as UIImageView:
                let imageDto = UpsertScreenRequest.View.Image(
                    isPresent: imageView.image != nil,
                    base64Image: imageView.image?.convertImageToBase64()
                )
                
                viewDto.type = .image
                viewDto.image = imageDto
                
            case _ as UITableView:
                let tableViewDto = UpsertScreenRequest.View.TableView()
                
                viewDto.type = .tableView
                viewDto.tableView = tableViewDto
                
            case let tableViewCell as UITableViewCell:
                let tableViewCellDto = UpsertScreenRequest.View.TableViewCell(
                    reuseIdentifier: tableViewCell.reuseIdentifier!
                )
                
                viewDto.type = .tableViewCell
                viewDto.tableViewCell = tableViewCellDto
                
            default:
                let group = UpsertScreenRequest.View.Group()
                
                viewDto.type = .group
                viewDto.group = group
            }
            
            createdViewDtos.append(viewDto)
        }
        
        return createdViewDtos
    }
    
    private func getConstraints(toList constraintDtos: inout [UpsertScreenRequest.Constraint], ofView view: UIView) {
        for constraint in view.constraints {
            let firstView: UIView! = constraint.firstItem as? UIView
            let secondView: UIView! = constraint.secondItem as? UIView
            
            if !constraint.isActive {
                continue
            }
            
            if firstView == nil || secondView == nil {
                continue
            }
            
            if constraint.relation != .equal {
                continue
            }
            
            if constraint.multiplier != 1.0 {
                continue
            }
            
            if constraint.priority.rawValue != 1000.0 {
                continue
            }
            
            if !isAttributeSupported(constraint.firstAttribute)
                || !isAttributeSupported(constraint.secondAttribute) {
                continue
            }
            
            // Continue when any of two views is not upsertable
            if !isViewUpsertable(firstView)
                || !isViewUpsertable(secondView) {
                continue
            }
            
            let attribute = getConvertedAttribute(constraint.firstAttribute)!
            let value = Double(/* constraint.multiplier * */ constraint.constant)
            let hasTarget = secondView != nil
            let targetViewUniqueId = hasTarget ? secondView!.identifier : nil
            let targetAttribute = hasTarget ? getConvertedAttribute(constraint.secondAttribute) : nil
            
            let constraintDto = UpsertScreenRequest.Constraint(
                viewUniqueId: firstView.identifier,
                attribute: attribute,
                value: value,
                hasTarget: hasTarget,
                targetViewUniqueId: targetViewUniqueId,
                targetAttribute: targetAttribute
            )
            
            let contains = constraintDtos.contains {
                $0.viewUniqueId == constraintDto.viewUniqueId
                && $0.attribute == constraintDto.attribute
                && $0.value == constraintDto.value
                && $0.hasTarget == constraintDto.hasTarget
                && $0.targetViewUniqueId == constraintDto.targetViewUniqueId
                && $0.targetAttribute == constraintDto.targetAttribute
            }
            
            // Continue if constraint already exists in list
            if contains {
                continue
            }
            
            constraintDtos.append(constraintDto)
        }
        
        for subview in view.subviews {
            getConstraints(toList: &constraintDtos, ofView: subview)
        }
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
    
    private func isAttributeSupported(_ attribute: NSLayoutConstraint.Attribute) -> Bool {
        let supportedConstraints: [NSLayoutConstraint.Attribute] = [
            .left, .right, .top, .bottom, .leading, .trailing
        ]
        
        return supportedConstraints.contains(attribute)
    }
    
    private func isViewUpsertable(_ view: UIView) -> Bool {
        if view.isHidden { return false }
        else if view.frame.isEmpty  { return false }
        
        return true
    }
    
    private func getLabel(fromUiLabel label: UILabel) -> UpsertScreenRequest.View.Label {
        let rgbaColor = label.textColor.asRGBA() ?? (0, 0, 0, 0)
        
        let font = UpsertScreenRequest.View.Label.Font(
            family: label.font.familyName,
            size: Int(label.font.pointSize),
            color: UpsertScreenRequest.View.Label.Font.Color.init(red: rgbaColor.red, green: rgbaColor.green, blue: rgbaColor.blue, alpha: rgbaColor.alpha),
            isBold: (label.font.fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0,
            isItalic: (label.font.fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0,
            isUnderlined: false /* TODO */,
            isStrikethrough: false /* TODO */
        )
        
        let labelDto = UpsertScreenRequest.View.Label(
            text: label.text ?? "",
            font: font
        )
        
        return labelDto
    }
}
