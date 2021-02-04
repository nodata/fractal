//
//  Switch.swift
//  DesignSample
//
//  Created by Anthony Smith on 11/09/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

public final class Switch: UISwitch {

    public var dark: Bool = false { didSet { updateForDark() }}

    public init() {
        super.init(frame: .zero)
        layer.cornerRadius = bounds.size.height/2
        setForBand()
    }

    @available (*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setForBand() {
        thumbTintColor = .atom(.switchThumbTint)
        backgroundColor = .atom(.switchNegativeTint)
        tintColor = .atom(.switchNegativeTint)
        onTintColor = .atom(.switchPositiveTint)
    }

    private func updateForDark() {
        thumbTintColor = dark ? .text : nil
    }
}
