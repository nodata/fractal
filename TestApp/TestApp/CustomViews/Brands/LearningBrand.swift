//
//  LearningBrand.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 10/30/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import Foundation
import DesignSystem

class LearningBrand: Brand {
    
    var id: String = "LearningBrand"
    
    var keyboardAppearance: UIKeyboardAppearance = .dark
    
    var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    
    var defaultCellHeight: CGFloat = 52.0
    
    func imageName(for key: UIImage.Key) -> String? {
        switch key {
        default:
            return key.rawValue
        }
    }
}

// MARK: - Spacing / Sizes
extension LearningBrand {

    func cornerRadius(for key: CGFloat.Key) -> CGFloat { return 0.0 }
    
    func floatValue(for key: CGFloat.Key) -> CGFloat {
        switch key {
        case .xxsmall:
            return 2
        case .xsmall:
            return 4
        case .small:
            return 8
        case .medium:
            return 16
        case .large:
            return 24
        case .xlarge:
            return 32
        case .xxlarge:
            return 64
        case .xxxlarge:
            return 128
        case .keyline:
            return 16
        case .divider:
            return 1
        case .padding:
            return 8
        default:
            return 0
        }
    }
    
    func size(for key: CGSize.Key) -> CGSize {
        switch key {
        case .iconxsmall:
            return CGSize(width: 20.0, height: 20.0)
        case .iconsmall:
            return CGSize(width: 28.0, height: 28.0)
        case .iconmedium:
            return CGSize(width: 40.0, height: 40.0)
        case .iconlarge:
            return CGSize(width: 64.0, height: 64.0)
        case .iconxlarge:
            return CGSize(width: 96.0, height: 96.0)
        case .iconxxlarge:
            return CGSize(width: 128.0, height: 128.0)
        default:
            return .zero
        }
    }

}

// MARK: - Typography
extension LearningBrand {

    func fontName(for typography: Typography) -> String? {
//        if typography.isStrong {
//            switch typography {
//            case .xxlarge, .xlarge, .large:
//                return "Avenir-Black"
//            default:
//                return "Avenir-Medium"
//            }
//        }
        return "Roboto-Regular"
    }

    // Examples: ultraLight, thin, light, regular, medium, semibold, bold, heavy, strong, black
    
    func fontWeight(for typography: Typography) -> UIFont.Weight {

//        guard let name = fontName(for: typography) else { return .regular }
//
//        if name == "Avenir-Black" {
//            return .black
//        } else if name == "Avenir-Medium" {
//            return .medium
//        }

        return .regular
    }
    
    public func fontSize(for typography: Typography) -> CGFloat {
        var size: CGFloat
        
        switch typography {
        case .x5large:   //Num Pad Output
            size = 119
        case .x4large:   //Accent Request
            size = 75
        case .xxxlarge:  //Num Pad Output - small
            size = 61
        case .xxlarge:   //Accent Request - small
            size = 37
        case .xlarge:   //Large Header (& w/ Accent)
            size = 24
        case .large:    //Header
            size = 20
        case .medium:
            size = 16   //Secondary, Accent, Default Button
        case .small:
            size = 14
        case .xsmall:
            size = 12
        case .xxsmall:
            size = 10
        default:
            size = 16
        }
        
        if typography.useAccessibility {
            size += fontSizeAdjustment(for: typography)
        }
        
        return size
    }
    
    private func fontSizeAdjustment(for typography: Typography) -> CGFloat {
        switch (typography, BrandingManager.contentSizeCategory) {
        case (.xxsmall, .extraSmall),
             (.xxsmall, .small):
            return 0.0
        case (_, .extraSmall):
            return -2.0
        case (_, .small):
            return -1.0
        case (_, .extraLarge):
            return 1.0
        case (_, .extraExtraLarge):
            return 2.0
        case (_, .extraExtraExtraLarge):
            return 3.0
        case (_, .accessibilityMedium):
            return 4.0
        case (_, .accessibilityLarge):
            return 5.0
        case (_, .accessibilityExtraLarge):
            return 6.0
        case (_, .accessibilityExtraExtraLarge), (_, .accessibilityExtraExtraExtraLarge):
            return 7.0
        default: // unspecified, medium & large
            return 0.0
        }
    }
}

// MARK: - Colors
extension LearningBrand {

    func atomColor(for key: UIColor.Key) -> UIColor {
        switch key {
        case .primary:
            return .blue
        case .secondary:
            return .greyReallyDark
        case .shadow:
            return .shadow
        case .warning:
            return .red
        case .sliderPositiveTint:
            return .green
        case .sliderNegativeTint:
            return .mono3
        case .switchPositiveTint:
            return .lightGreen
        case .switchNegativeTint:
            return .mono5
        case .detailDisclosure:
            return .green
        case .check:
            return .green
        case .divider:
            return .mono5
        case .clear:
            return .clear
        default:
            return .green
        }
    }
    
    func brandColor(for key: UIColor.Key) -> UIColor {
        switch key {
        case .secondary:
            return .blueDark
        case .tertiary:
            return .missingColor
        default:
            return .blue
        }
    }
    
    func backgroundColor(for key: UIColor.Key) -> UIColor {
        switch key {
        case .primary:
            return .greyDark // .blue
        case .cellSelected:
            return UIColor(white: 0.0, alpha: 0.1)
        case .clear:
            return .clear
        case .secondary:
            return .mono5
        case .tertiary:
            return .mono3
        case .heroBg:
            return .mono5
        case .missing:
            return .red
        default:
            return .greyDark
        }
    }
    
    func textColor(for key: UIColor.Key) -> UIColor {
        switch key {
        case .secondary:
            return .whiteDark
        case .secondaryDisabled:
            return .greyDisabled
        case .tertiary:
            return .blue    //accentRequest
        case .secondaryDark:
            return .blueDark
        default: //.primary
            return .white
        }
    }
}

fileprivate extension UIColor {
    static let           blue     = #colorLiteral(red: 0.2392156863, green: 0.4549019608, blue: 0.9058823529, alpha: 1) // #3D74E7                  // Primary buttons, prominent ui elements, Main text
    static let       blueDark     = #colorLiteral(red: 0.2392156863, green: 0.4549019608, blue: 0.9058823529, alpha: 0.5) // #3D74E780 (50% Opacity)  // Accent text, accent icons
    static let          white     = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // #FFFFFF                  // Primary text and icons
    static let      whiteDark     = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5) // #FFFFFF80 (50% Opacity)  // secondary text and icons
    static let      greyDisabled  = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.23) // #FFFFFF3B (23% Opacity)  // secondary text and icons
    static let           grey     = #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2078431373, alpha: 1) // #333435                  // secondary buttons, tertiary icons
    static let       greyDark     = #colorLiteral(red: 0.1450980392, green: 0.1490196078, blue: 0.1529411765, alpha: 1) // #252627                  // app background
    static let greyReallyDark     = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 0.23) // #6464643B (23% Opacity)  // Secondary buttons
    static let   missingColor     = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    
    /* Original Template colors */
    //TODO: jbott - 10.30.19 - remove older colors after filling out brand
    static let lightGreen = #colorLiteral(red: 0.527, green: 0.802, blue: 0.684, alpha: 1)
    static let green      = #colorLiteral(red: 0.427, green: 0.702, blue: 0.584, alpha: 1)
    static let darkGreen  = #colorLiteral(red: 0.327, green: 0.602, blue: 0.484, alpha: 1)
    static let red        = #colorLiteral(red: 0.714, green: 0.318, blue: 0.325, alpha: 1)
    static let mono6      = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
    static let mono5      = #colorLiteral(red: 0.129, green: 0.137, blue: 0.165, alpha: 1)
    static let mono4      = #colorLiteral(red: 0.176, green: 0.188, blue: 0.212, alpha: 1)
    static let mono3      = #colorLiteral(red: 0.243, green: 0.263, blue: 0.286, alpha: 1)
    static let mono2      = #colorLiteral(red: 0.455, green: 0.494, blue: 0.541, alpha: 1)
    static let mono       = #colorLiteral(red:0.890, green: 0.902, blue: 0.922, alpha: 1)
    static let shadow     = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.18)
}

public extension UIColor.Key {
    static let secondaryDark = UIColor.Key("secondaryDark")
    static let secondaryDisabled = UIColor.Key("secondaryDisabled")
}


extension LearningBrand: ButtonBrand {
    
    func widthPin(for size: Button.Size) -> Pin {
        return .width(-.keyline*2)
    }
    
    func heightPin(for size: Button.Size) -> Pin {
        return .height(asConstant: 48.0)
    }
    
    func height(for size: Button.Size.Height) -> CGFloat {
        return 48.0
    }
    
    func configure(_ button: Button, with style: Button.Style) {
        
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: .keyline, bottom: 0.0, right: .keyline)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -.keyline/2, bottom: 0.0, right: .keyline * 1.5)
        
        switch style {
        case .secondary:
            button.setTypography(.medium)
            button.layer.cornerRadius = 13
            button.setTitleColor(.text, for: .normal)
            button.setBackgroundColor(UIColor.atom(.secondary), for: .normal)
            button.setBackgroundColor(UIColor.atom(.secondary).darker(0.1), for: .highlighted)
            
        case .secondaryDisabled:
            button.setTypography(.medium)
            button.layer.cornerRadius = 13
            button.setTitleColor(.text(.secondaryDisabled), for: .normal)
            button.setBackgroundColor(UIColor.atom(.secondary), for: .normal)
            button.setBackgroundColor(UIColor.atom(.secondary).darker(0.1), for: .highlighted)
    
        //TODO: jbott - 11.1.19 - still need to define attention and toggle styles
        case .attention:
            button.setTypography(.medium)
            button.layer.cornerRadius = 24.0
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(UIColor.atom(.warning), for: .normal)
            button.setBackgroundColor(UIColor.atom(.warning).lighter(), for: .highlighted)
            button.layer.borderWidth = 0.0
        case .toggle:
            button.setTypography(.medium)
            button.layer.cornerRadius = 24.0
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(.brand, for: .normal)
            button.setBackgroundColor(UIColor.brand.lighter(0.1), for: .highlighted)
            button.setBackgroundColor(UIColor.brand.lighter(0.1), for: .selected)
            button.layer.borderWidth = 0.0
            
            
        case .primary: fallthrough
        default:
            button.setTypography(.medium)
            button.layer.cornerRadius = 13
            button.setTitleColor(.text, for: .normal)
            button.setBackgroundColor(UIColor.atom(.primary), for: .normal)
            button.setBackgroundColor(UIColor.atom(.primary).darker(0.1), for: .highlighted)
//            button.layer.borderWidth = 1.0
//            button.layer.borderColor = UIColor.brand.cgColor
        }
    }
}

extension LearningBrand: NavigationControllerBrand {
    func applyBrand(to navigationBar: UINavigationBar) {
        
        let attributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.font: Typography.large.font,
            NSAttributedString.Key.foregroundColor: UIColor.text(.secondary)]
        
        let largeAttributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.font: Typography.xxlarge.font,
            NSAttributedString.Key.foregroundColor: UIColor.text(.secondary)]
        
        navigationBar.titleTextAttributes = attributes
        navigationBar.largeTitleTextAttributes = largeAttributes
        navigationBar.shadowImage = UIImage(color: .background(.secondary))
        navigationBar.barTintColor = .background(.secondary)
        navigationBar.tintColor = .text(.secondary)
        navigationBar.isOpaque = true
    }
}

extension LearningBrand: TabBarControllerBrand {
    func applyBrand(to tabBar: UITabBar) {
        tabBar.shadowImage = UIImage(color: .atom(.divider))
        tabBar.barTintColor = .background
        tabBar.tintColor = .brand
    }
}

extension LearningBrand: BrandTest {
    public var allTypographyCases: [Typography] {
        let basicCases = Typography.allCases
        let str = basicCases.map { Typography($0.key, [.strong]) }
        let noAcc = basicCases.map { Typography($0.key, [.noAccessibility]) }
        let strNoAcc = basicCases.map { Typography($0.key, [.strong, .noAccessibility]) }
        return basicCases + str + noAcc + strNoAcc
    }
    
    var rawPalette: [BrandingManager.PaletteOption] {

        let array = [BrandingManager.PaletteOption(name: "light green", color: .lightGreen),
                     BrandingManager.PaletteOption(name: "green",       color: .green),
                     BrandingManager.PaletteOption(name: "dark green",  color: .darkGreen),
                     BrandingManager.PaletteOption(name: "mono6",       color: .mono6),
                     BrandingManager.PaletteOption(name: "mono5",       color: .mono5),
                     BrandingManager.PaletteOption(name: "mono4",       color: .mono4),
                     BrandingManager.PaletteOption(name: "mono3",       color: .mono3),
                     BrandingManager.PaletteOption(name: "mono2",       color: .mono2),
                     BrandingManager.PaletteOption(name: "mono",        color: .mono),
                     BrandingManager.PaletteOption(name: "shadow",      color: .shadow)]
        return array
    }
}

extension LearningBrand: HeroImageBrand {
    var heroCornerRadius: CGFloat {
        return .medium
    }
    
    var heroEdgeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: .keyline, left: .keyline, bottom: .keyline, right: .keyline)
    }
}
