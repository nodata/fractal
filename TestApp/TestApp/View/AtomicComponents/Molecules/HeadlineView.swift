//
//  HeadlineView.swift
//  DesignSystem
//
//  Created by Anthony Smith on 12/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import DesignSystem

public class HeadlineView: UIView {

    public enum Style: String {
        case `default`,
             detail,
             header,
             headerLarge,
             headerLargeAccent,
             secondary,
             secondaryAccent

        public var typography: Typography {
            switch self {
            case .header:
                return .large
            case .headerLarge, .headerLargeAccent:
                return .xlarge
            case .secondary, .secondaryAccent:
                return .medium
            case .default:
                return .large
            default: //detail
                return .medium
            }
        }

        public var color: UIColor {
            switch self {
            case .headerLargeAccent:
                return .text(.tertiary)
            case .secondary:
                return .text(.secondary)
            case .secondaryAccent:
                return .text(.secondaryDark)
            case .header, .headerLarge, .default: fallthrough
            default:
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

    private let style: Style

    public init(style: Style = .default, alignment: NSTextAlignment? = nil) {
        self.style = style
        super.init(frame: .zero)
        addSubview(label)
        
        var widthPin = Pin.width(-.keyline*2, options: [.relation(.lessThanOrEqual)])
        
        if let alignment = alignment {
            widthPin = Pin.width(-.keyline*2)
            label.textAlignment = alignment
        }
        
        label.pin(to: self, [.leading(.keyline),
                             .bottom(-.small),
                             .top(style.topPadding),
                             widthPin])
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(text: String) {
        label.text = text
    }

    // MARK: - Properties
    private lazy var label: Label = {
        let label = Label()
        label.apply(typography: self.style.typography, color: self.style.color)
        label.numberOfLines = 0
        return label
    }()
}
