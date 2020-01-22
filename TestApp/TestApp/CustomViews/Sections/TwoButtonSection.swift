//
//  TwoButtonSection.swift
//  
//
//  Created by Jonathan Bott on 11/4/19.
//

import Foundation
import DesignSystem

extension SectionBuilder {
    public func twoButtons(title1: String, title2: String, style1: Button.Style = .primary, style2: Button.Style = .primary, hiddenClosure: (() -> Bool)? = nil, tapped1Closure: @escaping VoidClosure, tapped2Closure: @escaping VoidClosure) -> TwoButtonSection {
        return TwoButtonSection(title1: title1, title2: title2, style1: style1, style2: style2, hiddenClosure: hiddenClosure, tapped1Closure: tapped1Closure, tapped2Closure: tapped2Closure)
    }
}

public class TwoButtonSection {

    fileprivate let title1: String
    fileprivate let title2: String
    fileprivate let style1: Button.Style
    fileprivate let style2: Button.Style
    fileprivate let tapped1Closure: VoidClosure
    fileprivate let tapped2Closure: VoidClosure
    fileprivate let buttonWidth: CGFloat
    fileprivate let padding: CGFloat
    
    
    fileprivate let hiddenClosure: (() -> Bool)?
    

    init(title1: String, title2: String, buttonWidth: CGFloat = 164, padding: CGFloat = 20, style1: Button.Style = .primary, style2: Button.Style = .primary, hiddenClosure: (() -> Bool)? = nil, tapped1Closure: @escaping VoidClosure, tapped2Closure: @escaping VoidClosure) {
        self.title1 = title1
        self.title2 = title2
        self.style1 = style1
        self.style2 = style2
        self.buttonWidth = buttonWidth
        self.padding = padding
        self.hiddenClosure = hiddenClosure
        self.tapped1Closure = tapped1Closure
        self.tapped2Closure = tapped2Closure
    }
}

extension TwoButtonSection: ViewSection {
    public var reuseIdentifier: String {
        return "TwoButtonSection_\(style1.rawValue)"
    }

    public func createView() -> UIView {
        return TwoButtonView(style1: style1, style2: style2, buttonWidth: buttonWidth, padding: padding)
    }

    public var itemCount: Int {
        guard let hiddenClosure = self.hiddenClosure else { return 1 }
        return hiddenClosure() ? 0 : 1
    }
    
    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        return SectionCellSize(width: view.bounds.size.width, height: nil)
    }

    public func configure(_ view: UIView, at index: Int) {
        (view as? TwoButtonView)?.set(buttonTitle1: title1, buttonTitle2: title2, closure1: tapped1Closure, closure2: tapped2Closure)
    }
}
