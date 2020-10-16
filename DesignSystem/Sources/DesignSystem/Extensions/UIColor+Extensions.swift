//
//  UIColor+Extensions.swift
//  DesignSample
//
//  Created by Anthony Smith on 28/08/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public convenience init?(color: UIColor) {
        
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIColor {

    private static let hexDivide: CGFloat = 255.0

    public convenience init?(red: Int, green: Int, blue: Int) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        self.init(red: CGFloat(red) / UIColor.hexDivide,
                  green: CGFloat(green) / UIColor.hexDivide,
                  blue: CGFloat(blue) / UIColor.hexDivide,
                  alpha: 1.0)
    }

    public convenience init?(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
    
    public convenience init?(hex: String?) {
        guard let hex = hex else { return nil }
        let string = hex.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue: UInt64 = 0
        Scanner(string: string).scanHexInt64(&rgbValue)
        let rgb = Int(rgbValue)
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
    
    public var luminosity: CGFloat {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        return ((r * 299.0) + (g * 587.0) + (b * 114.0)) / 1000.0
    }
    
    public func firstNonClashing(from colors: [UIColor]) -> UIColor? {
        for c in colors { if !clashes(with: c) { return c } }
        return nil
    }
    
    public func best(from colors: [UIColor]) -> UIColor {
        guard colors.count > 0 else { Assert("No colors passed to best(from colors)"); return self }
        var best: UIColor = colors[0]
        var luminosityDelta = abs(colors[0].luminosity - luminosity)
        
        for i in 1..<colors.count {
            let c = colors[i]
            let delta = abs(c.luminosity - luminosity)
            guard delta > luminosityDelta else { continue }
            best = c
            luminosityDelta = delta
        }
        
        return best
    }
    
    public func clashes(with color: UIColor, tolerance: CGFloat = 0.2) -> Bool {
        return abs(luminosity - color.luminosity) < tolerance
    }
    
    public var isVeryLight: Bool {
        return luminosity > 0.85
    }

    public var isLight: Bool {
        return luminosity > 0.7
    }
    
    public var isDark: Bool {
        return luminosity < 0.2
    }
    
    public var inverse: UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }
    
    public var hexString: String {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * UIColor.hexDivide) << 16 | (Int)(g * UIColor.hexDivide) << 8 | (Int)(b * UIColor.hexDivide) << 0

        return String(format: "#%06x", rgb)
    }

    public func hexString(noHashSymbol: Bool = false) -> String {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * UIColor.hexDivide) << 16 | (Int)(g * UIColor.hexDivide) << 8 | (Int)(b * UIColor.hexDivide) << 0
        let hash = noHashSymbol ? "" : "#"
        return String(format: "%@%06x", hash, rgb)
    }
    
    public func lighter(_ brightness: CGFloat = 0.25) -> UIColor {
        return colorWithAppendingBrightness(1 + brightness)
    }

    public func darker(_ brightness: CGFloat = 0.25) -> UIColor {
        return colorWithAppendingBrightness(1 - brightness)
    }

    public func alpha(_ alpha: CGFloat = 0.5) -> UIColor {
        return withAlphaComponent(alpha)
    }

    private func colorWithAppendingBrightness(_ aBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * aBrightness, alpha: alpha)
        }

        return self
    }

    public func equals(_ rhs: UIColor) -> Bool {
        var lhsR: CGFloat = 0.0
        var lhsG: CGFloat  = 0.0
        var lhsB: CGFloat = 0.0
        var lhsA: CGFloat  = 0.0
        getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)

        var rhsR: CGFloat = 0.0
        var rhsG: CGFloat  = 0.0
        var rhsB: CGFloat = 0.0
        var rhsA: CGFloat  = 0.0
        rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)

        return  lhsR == rhsR && lhsG == rhsG && lhsB == rhsB && lhsA == rhsA
    }
    
    public func mixed(with color: UIColor, percentage: CGFloat = 0.5) -> UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var r2: CGFloat = 0.0
        var g2: CGFloat = 0.0
        var b2: CGFloat = 0.0
        var a2: CGFloat = 0.0
        
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let finalR = ((1.0 - percentage) * r) + (percentage * r2)
        let finalG = ((1.0 - percentage) * g) + (percentage * g2)
        let finalB = ((1.0 - percentage) * b) + (percentage * b2)
        let finalA = ((1.0 - percentage) * a) + (percentage * a2)
        
        return UIColor(displayP3Red: finalR, green: finalG, blue: finalB, alpha: finalA)
    }
}

extension CGColor {

    public func equals(_ rhs: CGColor) -> Bool {
        
        guard let components = self.components, let rhsComponents = rhs.components else { return false}
        guard components.count == rhsComponents.count else { return false }
        
        for i in 0..<components.count {
            let c = components[i]
            let r = rhsComponents[i]
            guard c == r else { return false }
        }
        
        return true
    }
}
