//
//  VariableSizeLabelView.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 11/1/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import Foundation
import DesignSystem

public class VariableSizeLabelView: UIView {

    private var smallNumbersDefaultedToZero = true

    public enum Style: String {
        
        
        case `default`,
              numPadOutput,
              numPadOutputSmall,
              numPadOutputSmallDefault,
              accentRequest

        public var typography: Typography {
            switch self {
            case .numPadOutput:
                return .x5large
            case .numPadOutputSmall, .numPadOutputSmallDefault:
                return .xxxlarge
            case .accentRequest:
                return .x4large
            default: //default
                return .medium
            }
        }

        public var color: UIColor {
            switch self {
            case .accentRequest:
                return .text(.tertiary)
            case .numPadOutputSmallDefault:
                return .text(.secondary)
            case .numPadOutput, .numPadOutputSmall: fallthrough
            default: //default
                return .text
            }
        }

        public var topPadding: CGFloat {
            switch self {
            case .default:
                return .large
            default:
                return .medium
            }
        }
    }

    fileprivate let leftStyle: Style

    public init(leftStyle: Style = .default) {
        self.leftStyle = leftStyle
        super.init(frame: .zero)
        addSubview(label)
        label.pin(to: self, [.leading(.keyline),
                             .bottom(-.small),
                             .top(leftStyle.topPadding),
                             .width(-.keyline*2)])
        
        
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(attributedText: NSAttributedString) {
        label.attributedText = attributedText
    }

    // MARK: - Properties
    private lazy var label: UILabel = {
        let label = UILabel()
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
        return label
    }()
}

extension VariableSizeLabelView {
    static func attributedStringForCurrency(left: String?, right: String?, leftStyle: VariableSizeLabelView.Style, rightStyle: VariableSizeLabelView.Style) -> NSMutableAttributedString {

        // if both are empty
        // is both are not empty
        // if left is not empty && right is
        // if left is empty && right is not
        //"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: 119\">52</span> <span style='font-size: 61'>43</span>"
        
        let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center

        var preString = NSMutableAttributedString()
        
        if let left = left {
            let leftSize = leftStyle.typography.fontSize
            let leftColor = leftStyle.color.hexString
            preString = "<span style='font-size: \(leftSize); color: \(leftColor)'>\(left)</span>".htmlAttributedString!
        }
        
        if let right = right {
            let rightSize = rightStyle.typography.fontSize
            let rightColor = rightStyle.color.hexString
            
            let postString = "<span style='font-size: \(rightSize); color: \(rightColor)'>\(right)</span>".htmlAttributedString!
            
            let postRange = NSRange(location: 0, length: postString.length)
            
            postString.addAttributes([NSAttributedString.Key.baselineOffset:35, NSAttributedString.Key.paragraphStyle: style], range: postRange)
            preString.append(postString)
        }
        
        let wholeRange = NSRange(location: 0, length: preString.length)
        preString.addAttributes([NSAttributedString.Key.paragraphStyle: style], range: wholeRange)
                
        return preString
    }

}
