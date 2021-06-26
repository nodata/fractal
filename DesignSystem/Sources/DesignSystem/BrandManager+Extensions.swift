//
//  Button+BrandingManager.swift
//  Mercari
//
//  Created by Anthony Smith on 29/08/2018.
//  Copyright © 2018 Mercari, Inc. All rights reserved.
//

import UIKit

public extension Brand {
    var resourceBundle: Bundle? { return nil }
}

public extension Button.Style {
    static let primary   = Button.Style("primary")
    static let secondary = Button.Style("secondary")
    static let attention = Button.Style("attention")
    static let text      = Button.Style("text")
    static let toggle    = Button.Style("toggle")
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
    static let logo = Typography.Key("logo")
}

public extension CGFloat.Key {
    static let xxsmall      = CGFloat.Key("xxsmall")
    static let xsmall       = CGFloat.Key("xsmall")
    static let small        = CGFloat.Key("small")
    static let medium       = CGFloat.Key("medium")
    static let large        = CGFloat.Key("large")
    static let xlarge       = CGFloat.Key("xlarge")
    static let xxlarge      = CGFloat.Key("xxlarge")
    static let xxxlarge     = CGFloat.Key("xxxlarge")
    static let keyline      = CGFloat.Key("keyline")
    static let padding      = CGFloat.Key("padding")
    static let divider      = CGFloat.Key("divider")
    static let cornersmall  = CGFloat.Key("cornersmall")
    static let cornermedium = CGFloat.Key("cornermedium")
    static let cornerlarge  = CGFloat.Key("cornerlarge")
}

public extension CGSize.Key {
    static let xxsmall = CGSize.Key("xxsmall")
    static let xsmall  = CGSize.Key("xsmall")
    static let small   = CGSize.Key("small")
    static let medium  = CGSize.Key("medium")
    static let large   = CGSize.Key("iconlarge")
    static let xlarge  = CGSize.Key("iconxlarge")
    static let xxlarge = CGSize.Key("iconxxlarge")
}

public extension UIImage.Key {
    static let detailDisclosure = UIImage.Key("icn_disclosure_indicator")
    static let check            = UIImage.Key("check")
    static let smallArrow       = UIImage.Key("smallArrow")
}

public extension UIColor.Key {
    static let primary                    = UIColor.Key("primary")
    static let secondary                  = UIColor.Key("secondary")
    static let tertiary                   = UIColor.Key("tertiary")
    static let cell                       = UIColor.Key("cell")
    static let cellSelected               = UIColor.Key("cellSelected")
    static let detail                     = UIColor.Key("detail")
    static let information                = UIColor.Key("information")
    static let light                      = UIColor.Key("light")
    static let lightDetail                = UIColor.Key("lightDetail")
    static let divider                    = UIColor.Key("divider")
    static let segmentedDivider           = UIColor.Key("segmentedDivider")
    static let selectedTab                = UIColor.Key("selectedTab")
    static let unselectedTab              = UIColor.Key("unselectedTab")
    static let shadow                     = UIColor.Key("shadow")
    static let placeholder                = UIColor.Key("placeholder")
    static let refreshControl             = UIColor.Key("refreshControl")
    static let detailDisclosure           = UIColor.Key("detailDisclosure")
    static let switchPositiveTint         = UIColor.Key("switchPositiveTint")
    static let switchNegativeTint         = UIColor.Key("switchNegativeTint")
    static let switchThumbTint            = UIColor.Key("switchThumbTint")
    static let sliderPositiveTint         = UIColor.Key("sliderPositiveTint")
    static let sliderNegativeTint         = UIColor.Key("sliderNegativeTint")
    static let sliderThumbTint            = UIColor.Key("sliderThumbTint")
    static let positive                   = UIColor.Key("positive")
    static let negative                   = UIColor.Key("negative")
    static let warning                    = UIColor.Key("warning")
    static let clear                      = UIColor.Key("clear")
    static let missing                    = UIColor.Key("missing")
    static let segmentedControlHighlight  = UIColor.Key("segmentedControlHighlight")
    static let segmentedControl           = UIColor.Key("segmentedControl")
}
