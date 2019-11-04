//
//  Button+BrandingManager.swift
//  Mercari
//
//  Created by Anthony Smith on 29/08/2018.
//  Copyright © 2018 Mercari, Inc. All rights reserved.
//

import UIKit

public protocol ButtonBrand {
    func widthPin(for size: Button.Size) -> Pin
    func heightPin(for size: Button.Size) -> Pin
    func height(for size: Button.Size.Height) -> CGFloat
    func configure(_ button: Button, with style: Button.Style)
}

public extension Brand {
    var resourceBundle: Bundle? { return nil }
}

public extension CGSize { // IconSize

    static var xsmallIcon:  CGSize { return BrandingManager.brand.size(for: .iconxsmall) }
    static var smallIcon:   CGSize { return BrandingManager.brand.size(for: .iconsmall) }
    static var mediumIcon:  CGSize { return BrandingManager.brand.size(for: .iconmedium) }
    static var largeIcon:   CGSize { return BrandingManager.brand.size(for: .iconlarge) }
    static var xlargeIcon:  CGSize { return BrandingManager.brand.size(for: .iconxlarge) }
    static var xxlargeIcon: CGSize { return BrandingManager.brand.size(for: .iconxxlarge) }
}

public extension UIColor {

    static var atom:       UIColor { return .atom(.primary) }
    static var brand:      UIColor { return .brand(.primary) }
    static var background: UIColor { return .background(.primary) }
    static var text:       UIColor { return .text(.primary) }

    static func atom(_ key: UIColor.Key = .primary) -> UIColor {
        return BrandingManager.brand.atomColor(for: key)
    }

    static func brand(_ key: UIColor.Key = .primary) -> UIColor {
        return BrandingManager.brand.brandColor(for: key)
    }

    static func background(_ key: UIColor.Key = .primary) -> UIColor {
        return BrandingManager.brand.backgroundColor(for: key)
    }

    static func text(_ key: UIColor.Key = .primary) -> UIColor {
        return BrandingManager.brand.textColor(for: key)
    }
}

public extension CGFloat { // Spacing and size

    static var xxsmall:  CGFloat { return BrandingManager.brand.floatValue(for: .xxsmall) }
    static var xsmall:   CGFloat { return BrandingManager.brand.floatValue(for: .xsmall) }
    static var small:    CGFloat { return BrandingManager.brand.floatValue(for: .small) }
    static var medium:   CGFloat { return BrandingManager.brand.floatValue(for: .medium) }
    static var large:    CGFloat { return BrandingManager.brand.floatValue(for: .large) }
    static var xlarge:   CGFloat { return BrandingManager.brand.floatValue(for: .xlarge) }
    static var xxlarge:  CGFloat { return BrandingManager.brand.floatValue(for: .xxlarge) }
    static var xxxlarge: CGFloat { return BrandingManager.brand.floatValue(for: .xxxlarge) }

    static var padding:  CGFloat { return BrandingManager.brand.floatValue(for: .padding) }
    static var keyline:  CGFloat { return BrandingManager.brand.floatValue(for: .keyline) }
    static var divider:  CGFloat { return BrandingManager.brand.floatValue(for: .divider) }
}

public extension Button.Style {
    static let primary   = Button.Style("primary")
    static let secondary = Button.Style("secondary")
    static let attention = Button.Style("attention")
    static let text      = Button.Style("text")
    static let toggle    = Button.Style("toggle")

    static let primaryDisabled   = Button.Style("primaryDisabled")
    static let secondaryDisabled = Button.Style("secondaryDisabled")
}

public extension Typography.Key {
    static let xxxsmall = Typography.Key("xxxsmall")
    static let xxsmall  = Typography.Key("xxsmall")
    static let xsmall   = Typography.Key("xsmall")
    static let small    = Typography.Key("small")
    static let medium   = Typography.Key("medium")
    static let large    = Typography.Key("large")
    static let xlarge   = Typography.Key("xlarge")
    static let xxlarge  = Typography.Key("xxlarge")
    static let xxxlarge = Typography.Key("xxxlarge")
    static let x4large  = Typography.Key("x4large")
    static let x5large  = Typography.Key("x4large")
    static let x6large  = Typography.Key("x4large")
}

public extension CGFloat.Key {
    static let xxsmall  = CGFloat.Key("xxsmall")
    static let xsmall   = CGFloat.Key("xsmall")
    static let small    = CGFloat.Key("small")
    static let medium   = CGFloat.Key("medium")
    static let large    = CGFloat.Key("large")
    static let xlarge   = CGFloat.Key("xlarge")
    static let xxlarge  = CGFloat.Key("xxlarge")
    static let xxxlarge = CGFloat.Key("xxxlarge")
    static let keyline  = CGFloat.Key("keyline")
    static let padding  = CGFloat.Key("padding")
    static let divider  = CGFloat.Key("divider")
}

public extension CGSize.Key {
    static let iconxsmall   = CGSize.Key("iconxsmall")
    static let iconsmall    = CGSize.Key("iconsmall")
    static let iconmedium   = CGSize.Key("iconmedium")
    static let iconlarge    = CGSize.Key("iconlarge")
    static let iconxlarge   = CGSize.Key("iconxlarge")
    static let iconxxlarge  = CGSize.Key("iconxxlarge")
}

public extension UIImage.Key {
    static let detailDisclosure = UIImage.Key("icn_disclosure_indicator")
    static let check            = UIImage.Key("check")
    static let smallArrow       = UIImage.Key("smallArrow")
}

public extension UIColor.Key {
    static let primary            = UIColor.Key("primary")
    static let secondary          = UIColor.Key("secondary")
    static let tertiary           = UIColor.Key("tertiary")
    static let cell               = UIColor.Key("cell")
    static let cellSelected       = UIColor.Key("cellSelected")
    static let detail             = UIColor.Key("detail")
    static let information        = UIColor.Key("information")
    static let light              = UIColor.Key("light")
    static let divider            = UIColor.Key("divider")
    static let shadow             = UIColor.Key("shadow")
    static let placeholder        = UIColor.Key("placeholder")
    static let refreshControl     = UIColor.Key("refreshControl")
    static let detailDisclosure   = UIColor.Key("detailDisclosure")
    static let switchPositiveTint = UIColor.Key("switchPositiveTint")
    static let switchNegativeTint = UIColor.Key("switchNegativeTint")
    static let sliderPositiveTint = UIColor.Key("sliderPositiveTint")
    static let sliderNegativeTint = UIColor.Key("sliderNegativeTint")
    static let warning            = UIColor.Key("warning")
    static let clear              = UIColor.Key("clear")
    static let missing            = UIColor.Key("missing")
}
