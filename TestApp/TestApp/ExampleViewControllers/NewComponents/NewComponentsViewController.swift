//
//  NewComponentsViewController.swift
//  TestApp
//
//  Created by Jonathan Bott on 11/4/19.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation
import DesignSystem

class NewComponentsViewController: SectionTableViewController, SectionBuilder {

    override func viewDidLoad() {
        title = "NewComponentsViewController"
        super.viewDidLoad()
        view.backgroundColor = .background
        setup()
    }

    func setup() {
        setSections()
        reload()
    }
    
    private func setSections() {
        dataSource.sections = [
            spacing(128),
            numPadOutput(9876.0446),
            headline("Some Text", style: .secondary, alignment: .center),
            spacing(121),
            twoButtons(title1: "Button 1", title2: "Button 2", style1: .secondary, style2: .primary, tapped1Closure: {
                print("Button 1 tapped")
            }, tapped2Closure: {
                print("Button 2 tapped")
            }),
            //            spacing(),
            //            singleButton("Primary", tappedClosure: {}),
            //            spacing(),
            //            singleButton("Secondary", style: .secondary, tappedClosure: {}),
            //            spacing(),
            //            singleButton("Secondary", style: .secondaryDisabled, tappedClosure: {}),
            
            spacing(400),
            singleButton("Dismiss", tappedClosure: { [weak self] in self?.dismiss(animated: true) }),
        ]
    }
}
