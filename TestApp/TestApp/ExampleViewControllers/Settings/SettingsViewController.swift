//
//  SettingsViewController.swift
//  TestApp
//
//  Created by anthony on 10/07/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation
import DesignSystem

class SettingsViewController: SectionTableViewController, SectionBuilder {

    private let darkModeObserved = Observed<Bool>(UserDefaults.standard.bool(forKey: "useDarkMode"))
    private var notificationObject: NSObjectProtocol?
    
    override func viewDidLoad() {
        title = "Settings"
        super.viewDidLoad()
        notificationObject = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: BrandingManager.didChange), object: nil, queue: nil) { [weak self] (_) in
            self?.setupUI()
            self?.reload()
        }
        darkModeObserved.addObserver(self) { [weak self] value in self?.setForDark(value) }
        setupUI()
        setSections()
        reload()
    }

    private func setupUI() {
        setSections()
        setupTableView()
        view.backgroundColor = .background
    }
    
    private func setSections() {
        dataSource.sections = [
            image(.logo, heightType: .custom(200.0)),
            headline("Alternate Icons"),
            iconSelectionCarousel(),
            group([
                switchOption("Dark Mode", observedBool: darkModeObserved),
                information("Version", detailClosure: { "0.2" })
                ]),
            spacing(32.0),
            singleButton(BrandingManager.isDefaultBrand ? "Add Branding" : "Remove All Branding",
                         tappedClosure: { [weak self] in self?.brandingToggle() })
        ]
    }

    private func brandingToggle() {
        rebuildStack = true
        guard BrandingManager.isDefaultBrand else { BrandingManager.set(brand: nil); return }
        setForDark(darkModeObserved.value)
    }
    
    private func setForDark(_ darkMode: Bool) {
        rebuildStack = true
        UserDefaults.standard.set(darkMode, forKey: "useDarkMode")
        BrandingManager.set(brand: darkMode ? FractalDarkBrand() : FractalBrand())
    }
}
