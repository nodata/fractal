//
//  SectionTableViewController.swift
//  SectionSystem
//
//  Created by anthony on 11/12/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import UIKit

extension SectionTableViewController: SectionController {

    public var dataSource: SectionControllerDataSource { return data }

    public var didPullDownToRefreshClosure: (() -> Void)? {
        get { return refresh }
        set { refresh = newValue }
    }

    public func reloadSections(at indexes: [Int], animation: UITableView.RowAnimation) {
        reloadWillStart()
        
        if data.newSections {
            data.registerCells(in: self.tableView, with: &self.registeredReuseIdentifiers)
        }

        data.notifySectionsOfReload(in: indexes)

        func refresh() {
            if animation == .none {
                if indexes.count > 0 {
                    UIView.performWithoutAnimation {
                        tableView.reloadSections(IndexSet(indexes), with: .none)
                        finished()
                    }
                } else {
                    tableView.reloadData()
                    finished()
                }
            } else {

                let sectionIndexes = indexes.count == 0 ? Array(0..<dataSource.sections.count) : indexes
                var insertIndexPaths = [IndexPath]()
                var removeIndexPaths = [IndexPath]()
                
                for i in sectionIndexes {
                    let s = dataSource.sections[i]
                    guard i < tableView.numberOfSections else { continue }
                    insertIndexPaths += s.indexesToAdd.map { IndexPath(item: $0, section: i) }
                    removeIndexPaths += s.indexesToRemove.map { IndexPath(item: $0, section: i) }
                }
                
                if insertIndexPaths.count + removeIndexPaths.count == 0 {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    finished()
                } else {
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertIndexPaths, with: animation)
                    tableView.deleteRows(at: removeIndexPaths, with: animation)
                    tableView.endUpdates()
                    finished()
                }
            }
        }
        
        DispatchQueue.main.async {
            guard self.useRefreshControl else { refresh(); return }
            if self.refreshControl?.isRefreshing ?? false {
                self.perform(#selector(self.reloadRefresh), with: nil, afterDelay: 0.4, inModes: [RunLoop.Mode.common])
            } else {
                refresh()
            }
        }
    }
    
    @objc private func reloadRefresh() {
        tableView.reloadData()
        refreshControl?.perform(#selector(refreshControl?.endRefreshing), with: nil, afterDelay: 0.1, inModes: [RunLoop.Mode.common])
        perform(#selector(finished), with: nil, afterDelay: 0.1, inModes: [RunLoop.Mode.common])
    }
    
    @objc private func finished() {
        for s in dataSource.sections { s.didReload() }
        reloadDidFinish()
    }
    
    @objc open func reloadWillStart() {
        
    }
    
    @objc open func reloadDidFinish() {
        
    }
}

open class SectionTableViewController: UITableViewController {

    private let useRefreshControl: Bool
    private var registeredReuseIdentifiers: Set<String> = []
    private var data: SectionControllerDataSource!
    private var configureTableView: ((UITableView) -> Void)?
    private var notificationObject: NSObjectProtocol?
    public var refresh: (() -> Void)?
    public var tearDownOnBrandChange: Bool = true

    public var didScrollClosure: ((UIScrollView) -> Void)? {
        get { return data.didScroll }
        set { data.didScroll = newValue }
    }
    
    public var didEndDecelerating: ((UIScrollView) -> Void)? {
        get { data.didEndDecelerating }
        set { data.didEndDecelerating = newValue }
    }
    
    public var didEndScrollingAnimation: ((UIScrollView) -> Void)? {
        get { data.didEndScrollingAnimation }
        set { data.didEndScrollingAnimation = newValue }
    }
    
    public init(useRefreshControl: Bool = false, configureTableView: ((UITableView) -> Void)? = nil) {
        self.useRefreshControl = useRefreshControl
        self.configureTableView = configureTableView
        super.init(style: .plain)
        data = SectionControllerDataSource(viewController: self)
    }

    @available (*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = data
        tableView.delegate = data
        tableView.dragDelegate = data
        tableView.dropDelegate = data
        tableView.dragInteractionEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
        
        if useRefreshControl {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
            control.tintColor = refreshControlTintColor
            refreshControl = control
        }

        configureTableView?(tableView)

        notificationObject = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BrandingManager.didChangeNotification), object: nil, queue: nil) { [weak self] (_) in
            guard let `self` = self else { return }
            guard self.tearDownOnBrandChange else { return }
            self.tearDownSections()
        }
    }

    deinit {
        if let observer = notificationObject {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @objc open func refreshTriggered() {
        didPullDownToRefreshClosure?()
    }
    
    private func tearDownSections() {
        let indexPath = tableView.indexPathForRow(at: CGPoint(x: tableView.bounds.size.width/2, y: tableView.bounds.size.height/2))
        dataSource.tearDownCellSubviews()
        reload()
        guard let ip = indexPath else { return }
        tableView.scrollToRow(at: ip, at: .middle, animated: false)
    }

    // MARK: - Accessors

    open var refreshControlTintColor: UIColor {
        return .atom(.refreshControl)
    }
}
