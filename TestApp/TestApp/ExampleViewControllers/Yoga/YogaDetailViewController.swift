//
//  YogaDetailViewController.swift
//  TestApp
//
//  Created by anthony on 26/08/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation
import DesignSystem

class YogaDetailViewController: SectionCollectionViewController, SectionBuilder {

    var presenter: YogaDetailPresenter!

    init(event: YogaEvent) {
        super.init(useRefreshControl: false)
        DependencyRegistry.shared.prepare(viewController: self, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setSections()
        applyEvent()
        reload()
    }

    func inject(_ presenter: YogaDetailPresenter) {
        self.presenter = presenter
    }
    
    private func applyEvent() {
        title = presenter.event.title
    }
    
    private func setSections() {
        dataSource.sections = [
            heroImage(self.presenter.event._image),
            eventDetails("Every weekday 19:00\nWeekends 14:00", "$10"),
            singleButton("Book Session", tappedClosure: { print("Book session tapped") }),
            spacing(),
            headline("Description"),
            spacing(200.0, backgroundColorKey: .cellSelected),
            headline("Comments & Reviews"),
            spacing(),
            comments(with: self.presenter.comments)
        ]
    }
}
