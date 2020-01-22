//
//  VariableSizeLabelSection.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 11/1/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import Foundation
import DesignSystem

extension SectionBuilder {
    public func numPadOutput(_ amount: Double) -> VariableSizeLabelSection {
        let split = amount.splitStrings
        
        let title = VariableSizeLabelView.attributedStringForCurrency(left: split.left, right: split.right, leftStyle: .numPadOutput, rightStyle: .numPadOutputSmall)
        return VariableSizeLabelSection(.numPadOutput).enumerate({ [title] }) as! VariableSizeLabelSection
    }

    public func variableSizeLabel(_ title: NSAttributedString, leftStyle: VariableSizeLabelView.Style = .default, rightStyle: VariableSizeLabelView.Style = .default) -> VariableSizeLabelSection {
        return VariableSizeLabelSection(leftStyle).enumerate({ [title] }) as! VariableSizeLabelSection
    }
}

public class VariableSizeLabelSection {

    fileprivate let leftStyle: VariableSizeLabelView.Style
    fileprivate let rightStyle: VariableSizeLabelView.Style

    public init(_ leftStyle: VariableSizeLabelView.Style = .default, _ rightStyle: VariableSizeLabelView.Style = .default) {
        self.leftStyle  = leftStyle
        self.rightStyle = rightStyle
    }
}

extension VariableSizeLabelSection: ViewSection {

    public var reuseIdentifier: String {
        return "VariableSizeLabelSection_\(leftStyle.rawValue)"
    }

    public func createView() -> UIView {
        return VariableSizeLabelView(leftStyle: leftStyle)
    }

    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        return SectionCellSize(width: view.bounds.size.width, height: nil)
    }
    
    public func configure(_ view: UIView, at index: Int) {
        (view as? VariableSizeLabelView)?.set(attributedText: data[index])
    }
}

extension VariableSizeLabelSection: EnumeratableSection {
    public typealias DataType = NSAttributedString
}
