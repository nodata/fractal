//
//  SegmentedControlView.swift
//  DesignSystem
//
//  Created by acantallops on 2019/04/25.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation
import DesignSystem

protocol SegmentedControlViewDelegate: class {
    func selected(_ index: Int)
}

class SegmentedControlView: UIView {
    
    private weak var delegate: SegmentedControlViewDelegate?
    
    init() {
        super.init(frame: .zero)
        addSubview(segmentedControl)
        segmentedControl.pin(to: self, [.centerY,
                                        .leading(.keyline),
                                        .trailing(-.keyline),
                                        .height(asConstant: SegmentedControl.height)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(titles: [String], selectedIndex: Int, delegate: SegmentedControlViewDelegate) {
        segmentedControl.set(titles, selectedIndex: selectedIndex)
        self.delegate = delegate
    }
    
    func set(selectedIndex: Int) {
        guard selectedIndex >= 0 && selectedIndex < segmentedControl.numberOfSegments else { return }
        segmentedControl.selectedSegmentIndex = selectedIndex
    }
    
    @objc private func selected() {
    }
    
    // MARK: - Properties
    
    private lazy var segmentedControl: SegmentedControl = {
        let control = SegmentedControl()
        control.valueChangedClosure = { [weak self] (index) in
            self?.delegate?.selected(index)
        }
        return control
    }()
}
