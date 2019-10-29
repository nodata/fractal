//
//  TypographyOptionsViewModel.swift
//  DesignSystemApp
//
//  Created by anthony on 15/01/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation
import DesignSystem

extension SectionBuilder {
    public func typographyOptions(_ optionsClosure: @escaping () -> ([Typography])) -> TypographyOptionSection {
        return TypographyOptionSection(optionsClosure: optionsClosure)
    }
}

public class TypographyOptionSection {
    let optionsClosure: () -> ([Typography])

    init(optionsClosure: @escaping () -> ([Typography])) {
        self.optionsClosure = optionsClosure
    }

    fileprivate func name(for typography: Typography) -> String {
        return "\(typography.font.fontName) \(typography.fontSize)"
    }
}

extension TypographyOptionSection: ViewSection {

    public func createView() -> UIView {
        return TypographyOptionView()
    }

    public func size(in view: UIView, at index: Int) -> SectionCellSize {
        let option = self.optionsClosure()[index]
        let height = self.name(for: option).height(typography: option, width: view.bounds.size.width - .keyline*2)
        let height2 = option.name.height(typography: .small, width: view.bounds.size.width - .keyline*2)
        return SectionCellSize(width: view.bounds.size.width, height: height + height2 + .small*2)
    }

    public var itemCount: Int {
        return self.optionsClosure().count
    }

    public func configure(_ view: UIView, at index: Int) {
        let option = self.optionsClosure()[index]
        (view as? TypographyOptionView)?.set(name: self.name(for: option), typography: option)
    }
}
