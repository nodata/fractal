//
//  SectionController.swift
//  SectionSystem
//
//  Created by anthony on 21/12/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

public protocol SectionController {
    func reload(animation: UITableView.RowAnimation)
    func reloadSections(at indexes: [Int], animation: UITableView.RowAnimation)
    var didPullDownToRefreshClosure: (() -> Void)? { get set }
    var dataSource: SectionControllerDataSource { get }
}

public extension SectionController {
    
    func reload() {
        reloadSections(at: [], animation: .none)
    }
    
    func reload(animation: UITableView.RowAnimation) {
        reloadSections(at: [], animation: animation)
    }
}


public typealias SectionViewController = UIViewController & SectionController
