//
//  BrandManager.swift
//  Mercari
//
//  Created by Anthony Smith on 28/08/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

infix operator ====

public protocol Brandable {
    func setForBrand()
}

public protocol Brand {

    var id: String { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var defaultCellHeight: CGFloat { get }
    var resourceBundle: Bundle? { get }

    func imageName(for key: UIImage.Key) -> String?

    // Spacing and Sizing
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
    var rawPalette: [PaletteOption] { get }
    var allTypographyCases: [Typography] { get }
}

public struct PaletteOption {
    public let name: String
    public let color: UIColor
    
    public init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}

public class BrandManager {

    public static let didChangeNotification = "BrandingManager_BrandDidChange"
    public static let contentSizeOverrideKey = "BrandingManager_contentSizeCategory_override"
    public static let contentSizeOverrideValueKey = "BrandingManager_contentSizeCategory_value"

    public static let shared = BrandManager()
    
    public var dateManager: DateManager!
    public var brand: Brand = DefaultBrand() { didSet { brandDidChange() } }

    public weak var rootViewController: UIViewController?
    
    private var notificationObject: NSObjectProtocol?
    private var initialLoad = true
    
    init() {
        notificationObject = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            self?.rebrandViewHierarchy()
        }
        
        dateManager = DateManager(brandManager: self)
    }

    public var contentSizeCategory: UIContentSizeCategory {
        if UserDefaults.standard.bool(forKey: BrandManager.contentSizeOverrideKey) {
            return UIContentSizeCategory(rawValue: UserDefaults.standard.string(forKey: BrandManager.contentSizeOverrideValueKey) ?? "medium")
        }
        return UIApplication.shared.preferredContentSizeCategory
    }
    
    public func brandDidChange() {
        
        print("brandDidChange:", brand.id)
        
        if !initialLoad, let root = rootViewController, let snapshot = root.view.snapshotView(afterScreenUpdates: true) {
            root.view.addSubview(snapshot)
            snapshot.pin(to: root.view)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                snapshot.alpha = 0.0
            } completion: { (finished) in
                snapshot.removeFromSuperview()
            }
        }
        
        initialLoad = false
        rebrandViewHierarchy()
    }
    
    private func rebrandViewHierarchy() {
        
        guard let root = rootViewController else {
            print("No rootViewController set on BrandManager, unable to rebrand hierarchy")
            return
        }

        var views = [UIView]()
        var vcs = [UIViewController]()
        
        func applyTo(view: UIView) {
            for v in view.subviews { applyTo(view: v) }
            if view as? Brandable != nil { views.append(view) }
        }
        
        func applyTo(viewController: UIViewController) {
            applyTo(view: viewController.view)
            
            if viewController as? Brandable != nil {
                vcs.append(viewController)
            }
            
            if viewController.presentedViewController as? Brandable != nil {
                vcs.append(viewController.presentedViewController!)
                applyTo(viewController: viewController.presentedViewController!)
            }
            
            if let navigationController = viewController as? UINavigationController {
                for vc in navigationController.viewControllers { applyTo(viewController: vc) }
                applyTo(viewController: navigationController)
            }
            
            for vc in viewController.children { applyTo(viewController: vc) }
        }
        
        applyTo(viewController: root)
        for b in Set(views) { (b as? Brandable)?.setForBrand() }
        for b in Set(vcs) { (b as? Brandable)?.setForBrand() }
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
        public static let condensed = Modifier("condensed")
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
        let name = BrandManager.shared.brand.fontName(for: self)
        let defaultFont: UIFont = .systemFont(ofSize: fontSize, weight: fontWeight)
        guard let fontName = name else { return defaultFont }
        guard let font = UIFont(name: fontName, size: fontSize) else {
            print("Couldn't set font named \(name ?? ""), remember it's not the file name it's the actual font name, take a look in UIFont.familyNames : fontNames(forFamilyName:) and see if matches")
            return defaultFont
        }
        return font
    }

    public func font(overriddenPointSize: CGFloat) -> UIFont {
        let name = BrandManager.shared.brand.fontName(for: self)
        let defaultFont: UIFont = .systemFont(ofSize: overriddenPointSize, weight: fontWeight)
        guard let fontName = name else { return defaultFont }
        return UIFont(name: fontName, size: overriddenPointSize) ?? defaultFont
    }

    // Apple font weights
    // ultraLight, thin, light, regular, medium, semibold, bold, heavy, strong, black
    public var fontWeight: UIFont.Weight {
        BrandManager.shared.brand.fontWeight(for: self)
    }

    public var useAccessibility: Bool { return !modifiers.contains(.noAccessibility) }

    public var isStrong: Bool { modifiers.contains(.strong) }

    public var fontSize: CGFloat { BrandManager.shared.brand.fontSize(for: self) }

    public var lineHeight: CGFloat { font.lineHeight }

    public var defaultColor: UIColor { .text }
}

public extension Typography {

    static let xxsmall = Typography(.xxsmall)
    static let xsmall  = Typography(.xsmall)
    static let small   = Typography(.small)
    static let medium  = Typography(.medium)
    static let large   = Typography(.large)
    static let xlarge  = Typography(.xlarge)
    static let xxlarge = Typography(.xxlarge)
    static let xxxlarge = Typography(.xxxlarge)

    static func xxsmall(_ modifier: Modifier) -> Typography { return Typography(.xxsmall, [modifier]) }
    static func xsmall(_ modifier: Modifier)  -> Typography { return Typography(.xsmall, [modifier]) }
    static func small(_ modifier: Modifier)   -> Typography { return Typography(.small, [modifier]) }
    static func medium(_ modifier: Modifier)  -> Typography { return Typography(.medium, [modifier]) }
    static func large(_ modifier: Modifier)   -> Typography { return Typography(.large, [modifier]) }
    static func xlarge(_ modifier: Modifier)  -> Typography { return Typography(.xlarge, [modifier]) }
    static func xxlarge(_ modifier: Modifier) -> Typography { return Typography(.xxlarge, [modifier]) }
    static func xxxlarge(_ modifier: Modifier) -> Typography { return Typography(.xxxlarge, [modifier]) }

    static func xxsmall(_ modifiers: [Modifier])  -> Typography { return Typography(.xxsmall, modifiers) }
    static func xsmall(_ modifiers: [Modifier])   -> Typography { return Typography(.xsmall, modifiers) }
    static func small(_ modifiers: [Modifier])    -> Typography { return Typography(.small, modifiers) }
    static func medium(_ modifiers: [Modifier])   -> Typography { return Typography(.medium, modifiers) }
    static func large(_ modifiers: [Modifier])    -> Typography { return Typography(.large, modifiers) }
    static func xlarge(_ modifiers: [Modifier])   -> Typography { return Typography(.xlarge, modifiers) }
    static func xxxlarge(_ modifiers: [Modifier]) -> Typography { return Typography(.xxxlarge, modifiers) }
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
        guard let name = BrandManager.shared.brand.imageName(for: key) else { return nil }

        if let bundle = bundle, let image = UIImage(named: name, in: bundle, compatibleWith: nil) { return image }

        if let bundle = BrandManager.shared.brand.resourceBundle, let image = UIImage(named: name, in: bundle, compatibleWith: nil) { return image }

        if let image = UIImage(named: name, in: .main, compatibleWith: nil) { return image }

        if let image = UIImage(named: name, in: Bundle(for: BrandManager.self), compatibleWith: nil) { return image }

        print("Failed to find \(key.rawValue) in any bundle")
        return nil
    }
}

public extension CGSize { // IconSize

    static var xxSmallIcon: CGSize { BrandManager.shared.brand.size(for: .xxsmall) }
    static var xSmallIcon:  CGSize { BrandManager.shared.brand.size(for: .xsmall) }
    static var smallIcon:   CGSize { BrandManager.shared.brand.size(for: .small) }
    static var mediumIcon:  CGSize { BrandManager.shared.brand.size(for: .medium) }
    static var largeIcon:   CGSize { BrandManager.shared.brand.size(for: .large) }
    static var xLargeIcon:  CGSize { BrandManager.shared.brand.size(for: .xlarge) }
    static var xxLargeIcon: CGSize { BrandManager.shared.brand.size(for: .xxlarge) }
}

public extension UIColor {

    static var atom:       UIColor { .atom(.primary) }
    static var brand:      UIColor { .brand(.primary) }
    static var background: UIColor { .background(.primary) }
    static var text:       UIColor { .text(.primary) }

    static func atom(_ key: UIColor.Key = .primary) -> UIColor { BrandManager.shared.brand.atomColor(for: key) }

    static func brand(_ key: UIColor.Key = .primary) -> UIColor { BrandManager.shared.brand.brandColor(for: key) }

    static func background(_ key: UIColor.Key = .primary) -> UIColor { BrandManager.shared.brand.backgroundColor(for: key) }
    static func text(_ key: UIColor.Key = .primary) -> UIColor { BrandManager.shared.brand.textColor(for: key) }
}

public extension CGFloat { // Spacing and size

    static var xxsmall:  CGFloat { return BrandManager.shared.brand.floatValue(for: .xxsmall) }
    static var xsmall:   CGFloat { return BrandManager.shared.brand.floatValue(for: .xsmall) }
    static var small:    CGFloat { return BrandManager.shared.brand.floatValue(for: .small) }
    static var medium:   CGFloat { return BrandManager.shared.brand.floatValue(for: .medium) }
    static var large:    CGFloat { return BrandManager.shared.brand.floatValue(for: .large) }
    static var xlarge:   CGFloat { return BrandManager.shared.brand.floatValue(for: .xlarge) }
    static var xxlarge:  CGFloat { return BrandManager.shared.brand.floatValue(for: .xxlarge) }
    static var xxxlarge: CGFloat { return BrandManager.shared.brand.floatValue(for: .xxxlarge) }

    static var padding:  CGFloat { return BrandManager.shared.brand.floatValue(for: .padding) }
    static var keyline:  CGFloat { return BrandManager.shared.brand.floatValue(for: .keyline) }
    static var divider:  CGFloat { return BrandManager.shared.brand.floatValue(for: .divider) }
    
    static var smallCornerRadius: CGFloat { return BrandManager.shared.brand.floatValue(for: .cornersmall) }
    static var mediumCornerRadius: CGFloat { return BrandManager.shared.brand.floatValue(for: .cornermedium) }
    static var largeCornerRadius: CGFloat { return BrandManager.shared.brand.floatValue(for: .cornerlarge) }
}

public extension UIKeyboardAppearance {
    static var brandKeyboardAppearance: UIKeyboardAppearance { BrandManager.shared.brand.keyboardAppearance }
}

public extension UIContentSizeCategory {
    static var managedContentSizeCategory: UIContentSizeCategory { BrandManager.shared.contentSizeCategory }
}
