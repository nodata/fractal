//
//  BrandingManager.swift
//  Mercari
//
//  Created by Anthony Smith on 28/08/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

// Brand, Spacing, Typography, Colour
// Convienience for accessing the raw style level of the DesignSystem

private var notificationObject: NSObjectProtocol?
private var currentBrand: Brand?
private var globalDateManager = DateManager()

infix operator ====

public protocol Brand {

    var id: String { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var defaultCellHeight: CGFloat { get }
    var resourceBundle: Bundle? { get }

    func imageName(for key: UIImage.Key) -> String?

    // Spacing and Sizing
    func cornerRadius(for key: CGFloat.Key) -> CGFloat
    func floatValue(for key: CGFloat.Key) -> CGFloat
    func size(for key: CGSize.Key) -> CGSize

    // Typograhy
    func fontName(for typography: Typography) -> String?
    func fontWeight(for typography: Typography) -> UIFont.Weight
    func fontSize(for typography: Typography) -> CGFloat

    // Colors
    func atomColor(for key: UIColor.Key) -> UIColor
    func brandColor(for key: UIColor.Key) -> UIColor
    func backgroundColor(for key: UIColor.Key) -> UIColor
    func textColor(for key: UIColor.Key) -> UIColor
}

protocol BrandTest {
    var rawPalette: [BrandingManager.PaletteOption] { get }
    var allTypographyCases: [Typography] { get }
}

public class BrandingManager {

    public static let didChange = "BrandingManager_BrandDidChange"
    public static let contentSizeOverrideKey = "BrandingManager_contentSizeCategory_override"
    public static let contentSizeOverrideValueKey = "BrandingManager_contentSizeCategory_value"

    public struct PaletteOption {
        public let name: String
        public let color: UIColor
        
        public init(name: String, color: UIColor) {
            self.name = name
            self.color = color
        }
    }

    public static func set(brand: Brand) {
        
        if let current = currentBrand {
            guard current.id != brand.id else { print("Current brand: \(current.id) id matches: \(brand.id)"); return }
        }
        
        currentBrand = brand
        print("Setting Brand:", brand.id)
        NotificationCenter.default.post(name: Notification.Name(rawValue: BrandingManager.didChange), object: nil)
    }

    public static var brand: Brand {
        if let brand = currentBrand { return brand }
        print("BrandingManager: No Brand set - Using DefaultBrand")
        let defaultBrand = DefaultBrand()
        currentBrand = defaultBrand
        return defaultBrand
    }

    public static var dateManager: DateManager {
        return globalDateManager
    }

    public static func subscribeToNotifications() {
        notificationObject = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { (_) in
            NotificationCenter.default.post(name: Notification.Name(rawValue: BrandingManager.didChange), object: nil)
        }
    }

    public static var contentSizeCategory: UIContentSizeCategory {
        if UserDefaults.standard.bool(forKey: BrandingManager.contentSizeOverrideKey) {
            return UIContentSizeCategory(rawValue: UserDefaults.standard.string(forKey: BrandingManager.contentSizeOverrideValueKey) ?? "medium")
        }
        return UIApplication.shared.preferredContentSizeCategory
    }
}

public struct Typography: CaseIterable, Equatable {

    public struct Key: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    // Key + Modifier determines the actual font properties under the hood in your brand

    public let key: Key
    public var modifiers: [Modifier]

    public struct Modifier: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Modifier, rhs: Modifier) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public static let strong = Modifier("strong")
        public static let noAccessibility = Modifier("noAccessibility")
    }

    public static func == (lhs: Typography, rhs: Typography) -> Bool {
        return lhs.name == rhs.name
    }

    public static func ==== (lhs: Typography, rhs: Typography) -> Bool {
        guard lhs == rhs else { return false }
        guard lhs.modifiers.count == rhs.modifiers.count else { return false }
        for mod in lhs.modifiers { guard rhs.modifiers.contains(mod) else { return false } }
        return true
    }

    public static var allCases: [Typography] {
        let basicCases = [.xxsmall, .xsmall, .small, .medium, large, xlarge, xxlarge]
        return basicCases
    }

    public init(_ key: Key, _ modifiers: [Modifier] = []) {
        self.key = key
        self.modifiers = modifiers
    }

    public var name: String {
        var string = key.rawValue
        if modifiers.contains(.strong) { string += " \(Modifier.strong.rawValue)" }
        if modifiers.contains(.noAccessibility) { string += " \(Modifier.noAccessibility.rawValue)" }
        return string
    }

    public var font: UIFont {
        let name = BrandingManager.brand.fontName(for: self)
        let defaultFont: UIFont = .systemFont(ofSize: fontSize, weight: fontWeight)
        guard let fontName = name else { return defaultFont }
        return UIFont(name: fontName, size: fontSize) ?? defaultFont
    }

    // Apple font weights
    // ultraLight, thin, light, regular, medium, semibold, bold, heavy, strong, black
    public var fontWeight: UIFont.Weight {
        return BrandingManager.brand.fontWeight(for: self)
    }

    public var useAccessibility: Bool { return !modifiers.contains(.noAccessibility) }

    public var isStrong: Bool { return modifiers.contains(.strong) }

    public var fontSize: CGFloat { return BrandingManager.brand.fontSize(for: self) }

    public var lineHeight: CGFloat { return font.lineHeight }

    public var defaultColor: UIColor { return .text } // TODO: put inside brand
}

public extension Typography {

    static let xxsmall = Typography(.xxsmall)
    static let xsmall  = Typography(.xsmall)
    static let small   = Typography(.small)
    static let medium  = Typography(.medium)
    static let large   = Typography(.large)
    static let xlarge  = Typography(.xlarge)
    static let xxlarge = Typography(.xxlarge)

    static func xxsmall(_ modifier: Modifier) -> Typography { return Typography(.xxsmall, [modifier]) }
    static func xsmall(_ modifier: Modifier)  -> Typography { return Typography(.xsmall, [modifier]) }
    static func small(_ modifier: Modifier)   -> Typography { return Typography(.small, [modifier]) }
    static func medium(_ modifier: Modifier)  -> Typography { return Typography(.medium, [modifier]) }
    static func large(_ modifier: Modifier)   -> Typography { return Typography(.large, [modifier]) }
    static func xlarge(_ modifier: Modifier)  -> Typography { return Typography(.xlarge, [modifier]) }
    static func xxlarge(_ modifier: Modifier) -> Typography { return Typography(.xxlarge, [modifier]) }

    static func xxsmall(_ modifiers: [Modifier]) -> Typography { return Typography(.xxsmall, modifiers) }
    static func xsmall(_ modifiers: [Modifier])  -> Typography { return Typography(.xsmall, modifiers) }
    static func small(_ modifiers: [Modifier])   -> Typography { return Typography(.small, modifiers) }
    static func medium(_ modifiers: [Modifier])  -> Typography { return Typography(.medium, modifiers) }
    static func large(_ modifiers: [Modifier])   -> Typography { return Typography(.large, modifiers) }
    static func xlarge(_ modifiers: [Modifier])  -> Typography { return Typography(.xlarge, modifiers) }
    static func xxlarge(_ modifiers: [Modifier]) -> Typography { return Typography(.xxlarge, modifiers) }
}

public extension UIImageView {
    convenience init(_ key: UIImage.Key, in bundle: Bundle? = nil, renderingMode: UIImage.RenderingMode = .alwaysOriginal) {
        self.init(image: UIImage.with(key, in: bundle)?.withRenderingMode(renderingMode))
    }
}

public extension CGFloat {
    struct Key: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
}

public extension CGSize {
    struct Key: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
}

public extension UIColor {
    struct Key: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
}

public extension UIImage {
    struct Key: Equatable, RawRepresentable {
        public let rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Key, rhs: Key) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    static func with(_ key: Key, in bundle: Bundle? = nil) -> UIImage? {
        guard let name = BrandingManager.brand.imageName(for: key) else { return nil }

        if let bundle = bundle, let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
            return image
        }

        if let bundle = BrandingManager.brand.resourceBundle, let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
            return image
        }

        if let image = UIImage(named: name, in: .main, compatibleWith: nil) {
            return image
        }

        if let image = UIImage(named: name, in: Bundle(for: BrandingManager.self), compatibleWith: nil) {
            return image
        }

        print("Failed to find \(key.rawValue) in any bundle")
        return nil
    }
}
