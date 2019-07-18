//
//  ViewController.swift
//  TestApp
//
//  Created by anthony on 23/04/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import UIKit
import DesignSystem

var rebuildStack = false

class ViewController: UIViewController {
    
    private var notificationObject: NSObjectProtocol?
    private var containedNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        notificationObject = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: BrandingManager.didChange), object: nil, queue: nil) { [weak self] (_) in
            guard rebuildStack else { return }
            self?.setupUI()
            rebuildStack = false
        }
        
        let cardViewController = CardViewController(topLevelViewController: navigationController)
        contain(cardViewController)
        cardViewController.view.superview?.alpha = 0.0 //TODO: find a way to put this inside CardViewController

        NavigationRouter.new(UINavigationController(), cardViewController)

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() { // HACK
        
        let vc = MainMenuViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.prefersLargeTitles = true
        
        let rootNC = NavigationRouter.shared.rootNavigationController
        if rootNC.viewControllers.count > 0  {
            nc.viewControllers = [MainMenuViewController(), SettingsViewController()]
        }
        rootNC.willMove(toParent:nil)
        rootNC.view.superview?.removeFromSuperview()
        rootNC.view.removeFromSuperview()
        rootNC.removeFromParent()
        
        contain(nc)
        NavigationRouter.shared.rootNavigationController = nc
    }
}

