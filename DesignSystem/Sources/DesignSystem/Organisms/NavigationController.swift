//
//  NavigationController.swift
//  TestApp
//
//  Created by anthony on 20/08/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation

public protocol NavigationControllerBrand {
    func applyBrand(to navigationBar: UINavigationBar)
}

public protocol BrandUpdateable: UIViewController { // TODO: maybe doesn't have to be a vc
    func brandWasUpdated()
}

public class NavigationController: UINavigationController, Brandable {

    override public func viewDidLoad() {
        super.viewDidLoad()
        setForBrand()
    }

    public func setForBrand() {
        applyBrand()
        updateViewControllers()
    }
    
    private func applyBrand() {
        guard let brand = BrandingManager.brand as? NavigationControllerBrand else {
            print("BrandingManager.brand does not conform to NavigationControllerBrand")
            return
        }
        brand.applyBrand(to: navigationBar)
    }
    
    private func updateViewControllers() {
        
        func updateIfPossible(_ vc: UIViewController) {
            if let updateable = vc as? BrandUpdateable { updateable.brandWasUpdated() }
            for vc in vc.children { updateIfPossible(vc) }
        }
        
        for vc in viewControllers {
            updateIfPossible(vc)
        }
    }
}
