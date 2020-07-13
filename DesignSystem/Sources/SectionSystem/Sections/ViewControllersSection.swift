//
//  ViewControllersSection.swift
//  DesignSystem
//
//  Created by Anthony Smith on 04/08/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation

extension SectionBuilder {
    public func viewControllers(_ viewControllers: [UIViewController]) -> [ViewControllersSection] {
        return viewControllers.map { ViewControllersSection($0) }
    }
}

public class ViewControllersSection {
    
    private let id: String
    private let viewController: UIViewController

    public init(_ viewController: UIViewController) {
        id = UUID().uuidString
        self.viewController = viewController
    }
}

extension ViewControllersSection: ViewControllerSection {
    
    public var reuseIdentifier: String { "VC_\(id)" }
    
    public func createViewController() -> UIViewController { viewController }
    
    public func size(in view: UIView, at index: Int) -> SectionCellSize { SectionCellSize(view) }
    
    public func configure(_ viewController: UIViewController, at index: Int) { }
}
