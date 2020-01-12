//
//  UIView+BrandingManager.swift
//  DesignSample
//
//  Created by Anthony Smith on 13/09/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

public protocol Highlightable {
    func set(for highlighted: Bool, selected: Bool)
}

public enum ShadowDirection {
    case up, down, left, right
}

extension CGColor {
    fileprivate static let shadowColor = UIColor.atom(.shadow).cgColor
}

extension CALayer {
    
    public func addShortShadow(_ direction: ShadowDirection = .down) {
        
        let size: CGFloat = 2.0
        
        switch direction {
        case .down:
            shadowOffset = CGSize(width: 0.0, height: size)
        case .up:
            shadowOffset = CGSize(width: 0.0, height: -size)
        case .left:
            shadowOffset = CGSize(width: -size, height: 0.0)
        case .right:
            shadowOffset = CGSize(width: size, height: 0.0)
        }
        
        shadowColor = CGColor.shadowColor
        shadowRadius = 2.0
        shadowOpacity = 0.2
    }

    public func addMediumShadow(_ direction: ShadowDirection = .down) {
        
        let size: CGFloat = 4.0
        
        switch direction {
        case .down:
            shadowOffset = CGSize(width: 0.0, height: size)
        case .up:
            shadowOffset = CGSize(width: 0.0, height: -size)
        case .left:
            shadowOffset = CGSize(width: -size, height: 0.0)
        case .right:
            shadowOffset = CGSize(width: size, height: 0.0)
        }
        
        shadowColor = CGColor.shadowColor
        shadowRadius = 2.0
        shadowOpacity = 0.2
    }
    
    public func addLongShadow(_ direction: ShadowDirection = .down) {
        
        let size: CGFloat = 6.0
        
        switch direction {
        case .down:
            shadowOffset = CGSize(width: 0.0, height: size)
        case .up:
            shadowOffset = CGSize(width: 0.0, height: -size)
        case .left:
            shadowOffset = CGSize(width: -size, height: 0.0)
        case .right:
            shadowOffset = CGSize(width: size, height: 0.0)
        }
        
        shadowColor = CGColor.shadowColor
        shadowRadius = 3.0
        shadowOpacity = 0.2
    }
    
    public func addHardInnerShadow(to sublayer: CALayer?, color: UIColor, size: CGFloat = 2.0, direction: ShadowDirection = .down) {
        
        guard let layer = sublayer else {
            let new = CALayer()
            addSublayer(new)
            addHardInnerShadow(to: new, color: color, size: size, direction: direction)
            return
        }
        
        layer.frame = CGRect(x: 0.0, y: direction == .down ? size : -size, width: bounds.size.width, height: bounds.size.height)
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = backgroundColor
        backgroundColor = color.cgColor
    }

    public func addInnerShadow(to sublayer: CALayer?) {
        guard let layer = sublayer else {
            let new = CALayer()
            addSublayer(new)
            addInnerShadow(to: new)
            return
        }
        
        layer.frame = CGRect(x: -2.0, y: 0.0, width: bounds.size.width + 4.0, height: bounds.size.height + 4.0)
        layer.cornerRadius = cornerRadius
        
        let roundedPath = UIBezierPath(roundedRect: layer.bounds.insetBy(dx: -1, dy: -1), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let reversePath = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).reversing()
        roundedPath.append(reversePath)
        
        layer.shadowPath = roundedPath.cgPath
        layer.masksToBounds = true
        layer.shadowColor = CGColor.shadowColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
    }
    
    public func removeShadow() {
        shadowColor = nil
        shadowOffset = .zero
        shadowRadius = 0.0
        shadowOpacity = 0.0
    }
}

extension UIView {
    
    public func addShortShadow(_ direction: ShadowDirection = .down) { layer.addShortShadow(direction) }
    
    public func addMediumShadow(_ direction: ShadowDirection = .down) { layer.addMediumShadow(direction) }
    
    public func addLongShadow(_ direction: ShadowDirection = .down) { layer.addLongShadow(direction) }
   
    public func removeShadow() { layer.removeShadow() }
}
