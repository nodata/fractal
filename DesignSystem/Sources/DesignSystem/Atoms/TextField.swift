//
//  TextField.swift
//  Mercari
//
//  Created by Anthony Smith on 26/03/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

final public class TextField: UITextField {
    
    static public let placeholderColor: UIColor = .text(.placeholder)
    
    override public var placeholder: String? {
        get { return attributedPlaceholder?.string }
        set { attributedPlaceholder = NSAttributedString(string: newValue ?? "", typography: typography, color: TextField.placeholderColor) }
    }

    public var typography: Typography = .medium { didSet { update() } }
    public var indexPath: IndexPath?
    public var willAutoClear: Bool = false
    public var key: String?
    
    public init() {
        super.init(frame: .zero)
        update()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        update()
    }

    private func setup() {
        font = typography.font
        textColor = .text
        tintColor = .brand
        backgroundColor = .clear
        keyboardAppearance = BrandingManager.brand.keyboardAppearance
    }
    
    private func update() {
        font = typography.font
        textColor = .text
    }
}
