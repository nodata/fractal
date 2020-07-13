//
//  Label.swift
//  Mercari
//
//  Created by Shinichiro Oba on 21/06/2018.
//  Copyright © 2018 Mercari, Inc. All rights reserved.
//

import UIKit

open class Label: UILabel {

    private var notificationObject: NSObjectProtocol?

    public var typography: Typography = .medium { didSet { lineHeight = numberOfLines == 1 ? 0.0 : typography.lineHeight } }
    public var actualLineHeight: CGFloat { return max(lineHeight, font.lineHeight) }
    public var underlineStyle: NSUnderlineStyle = [] { didSet { update() } }
    public var letterSpace: CGFloat = 0.0 { didSet { update() } }
    public var lineHeight: CGFloat = 0.0 { didSet { update() } }

    override public var font: UIFont! { get { return typography.font } set { } }
    override public var text: String? { didSet { update() } }
    override public var textAlignment: NSTextAlignment { didSet { update() } }

    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {
        if let observer = notificationObject {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setup() {
        notificationObject = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: BrandingManager.didChangeNotification), object: nil, queue: nil) { [weak self] (_) in
            self?.update()
        }
    }

    public func set(typography: Typography, color: UIColor? = nil) {
        self.typography = typography
        textColor = color ?? typography.defaultColor
    }

    private func update() {
        guard let text = text else { attributedText = nil; return }
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        attributedText = attributedString
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }
    
    public func addFont(_ font: UIFont, to substring: String) {
        guard let t = text else { return }
        let range = (t as NSString).range(of: substring)
        let attributedString = NSMutableAttributedString(string: t, attributes: attributes)
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributedText = attributedString
    }
    
    private var attributes: [NSAttributedString.Key: Any] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        var attr = [NSAttributedString.Key: Any]()
        attr[.font] = typography.font
        attr[.foregroundColor] = textColor
        attr[.paragraphStyle] = paragraphStyle
        attr[.underlineStyle] = underlineStyle.rawValue
        attr[.kern] = letterSpace
        
        return attr
    }
}
