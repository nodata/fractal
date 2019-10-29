//
//  SizeOptionsViewController.swift
//  DesignSystemApp
//
//  Created by anthony on 17/01/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation
import DesignSystem

class SizeOptionsViewController: UIViewController, SectionBuilder {

    private var sectionController: SectionViewController!
    private var iconToggled: Bool = false

    override func viewDidLoad() {
        title = "SizeOptionsVC"
        super.viewDidLoad()
        view.backgroundColor = .background
        DependencyRegistry.shared.prepare(viewController: self)

        sectionController.dataSource.sections = [headline("Spacing"),
                                                 spacing(),
                                                 sizeOptions(spacingOptions),
                                                 spacing(),
                                                 headline("Icon / Thumbnail"),
                                                 spacing(),
                                                 sizeOptions(iconSizeOptions),
                                                 spacing()]
        sectionController.reload()
    }

    func inject(sectionController: SectionViewController) {
        self.contain(sectionController)
        self.sectionController = sectionController
    }

    private var spacingOptions: [SizeOption] {
        
        let keys: [CGFloat.Key] = [.xxsmall,
                                  .xsmall,
                                  .small,
                                  .medium,
                                  .large,
                                  .xlarge,
                                  .xxlarge,
                                  .xxxlarge,
                                  .padding,
                                  .keyline,
                                  .divider]
        
        let options = keys.map { (key) -> SizeOption in
            let value = BrandingManager.brand.floatValue(for: key)
            let valueString = String(format: "%.0f", value)
            let name = "\(key.rawValue) \(valueString)"
            return Size(value: (name, CGSize(width: 0.0, height: value)))
        }

        return options
    }

    private var iconSizeOptions: [SizeOption] {

        let keys: [CGSize.Key] = [.iconxsmall,
                                  .iconsmall,
                                  .iconmedium,
                                  .iconlarge,
                                  .iconxlarge,
                                  .iconxxlarge]
        
        let options = keys.map { (key) -> SizeOption in
            let value = BrandingManager.brand.size(for: key)
            let valueString = String(format: "%.0fx%.0f", value.width, value.height)
            let name = "\(key.rawValue) \(valueString)"
            return Size(value: (name, value))
        }

        return options
    }
}

fileprivate struct Size: SizeOption {
    fileprivate let value: (String, CGSize)
    var name: String { return value.0 }
    var size: CGSize { return value.1 }
}
