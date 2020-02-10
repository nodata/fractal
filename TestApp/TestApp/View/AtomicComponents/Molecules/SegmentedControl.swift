//
//  SegmentedControl.swift
//  Manager
//
//  Created by Anthony Smith on 23/12/2019.
//  Copyright © 2019 nodata. All rights reserved.
//

import Foundation
import DesignSystem

class SegmentedControl: UIView {
    
    private static let inset: CGFloat = 2.0

    static let height: CGFloat = 32.0

    var valueChangedClosure: ((Int) -> Void)?
    var selectedSegmentIndex: Int = 0 { didSet { setForSelectedIndex(animatedTransition) }}
    
    var textColor: UIColor = .text { didSet { labelView.textColor = textColor }}
    var selectedTextColor: UIColor = .text { didSet { selectedLabelView.textColor = selectedTextColor }}
    var dividerColor: UIColor = .atom(.divider) { didSet { for d in dividers { d.backgroundColor = dividerColor } }}
    var selectedSegmentTintColor: UIColor = .background(.segmentedControlSelectedColor)
   
    private var dividers = [UIView]()
    private var panStartX: CGFloat = 0.0
    private var animatedTransition = false
    private(set) var numberOfSegments: Int = 0
    
    init() {
        super.init(frame: .zero)

        let tap = UITapGestureRecognizer(target: self, action: #selector(bgTapped))
        addGestureRecognizer(tap)
        
        addSubview(labelView)
        addSubview(panView)
        addSubview(selectedLabelView)

        labelView.pin(to: self)
        selectedLabelView.pin(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<numberOfSegments-1 {
            let x = segmentWidth * CGFloat(i+1)
            let divider = dividers[safe: i]
            divider?.isHidden = false
            divider?.frame = CGRect(x: x,
                                    y: labelView.bounds.size.height/4,
                                    width: SegmentedControl.inset,
                                    height: labelView.bounds.size.height/2)
        }
        
        setForSelectedIndex(false)
    }
    
    func set(_ items: [String], selectedIndex: Int) {
        
        guard items.count > 0 else { isHidden = true; return }
        
        if numberOfSegments != items.count {
            numberOfSegments = items.count
            
            if dividers.count != items.count {
                
                if dividers.count < items.count-1 {
                    let delta = (items.count-1) - dividers.count
                    
                    for _ in 0..<delta {
                        let divider = newDivider()
                        labelView.addSubview(divider)
                        dividers.append(divider)
                    }
                }
                
                if dividers.count > items.count-1 {
                    for divider in dividers { divider.isHidden = true }
                }
            }
        }
        
        isHidden = false
        selectedLabelView.strings = items
        labelView.strings = items
        setNeedsLayout()
        layoutIfNeeded()
        selectedSegmentIndex = selectedIndex
    }
    
    private func setDividersVisible(_ index: Int, _ percentage: CGFloat) {
        for i in 0..<dividers.count {
            let d = dividers[i]
            let v = 1.0 - percentage
            if i == index || i == index-1 { d.alpha = 1.0 - v }
            else if i == index+1 { d.alpha = v }
            else { d.alpha = 1.0 }
            d.isHidden = i > numberOfSegments-1
        }
    }
    
    private func setForSelectedIndex(_ animated: Bool) {
        
        let constant = (segmentWidth * CGFloat(selectedSegmentIndex)) + SegmentedControl.inset
        let frame = selectedViewFrame(with: constant)

        guard animatedTransition else {
            selectedLabelView.mask?.frame = frame
            panView.frame = frame
            setDividersVisible(selectedSegmentIndex, 0.0)
            valueChangedClosure?(selectedSegmentIndex)
            return
        }
        
        animatedTransition = false
        setNeedsLayout()
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: {
                        self.selectedLabelView.mask?.frame = frame
                        self.panView.frame = frame
                        self.setDividersVisible(self.selectedSegmentIndex, 0.0)
        }) { (finished) in
            self.valueChangedClosure?(self.selectedSegmentIndex)
        }
    }
    
    @objc private func bgTapped(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)
        animatedTransition = true
        selectedSegmentIndex = index(for: location.x)
    }

    @objc private func panned(_ pan: UIPanGestureRecognizer) {
        
        let location = pan.location(in: self)
        let velocity = pan.velocity(in: self)
        
        switch pan.state {
        case .began:
            panStartX = location.x - panView.frame.origin.x
        case .changed:
            let width = segmentWidth - SegmentedControl.inset*2
            let constant = max(SegmentedControl.inset, min(location.x - panStartX, bounds.size.width - (width + SegmentedControl.inset)))
            let frame = selectedViewFrame(with: constant)
            let i = index(for: constant)
            let total = segmentWidth * CGFloat(i)
            let percentage = (constant - total) / segmentWidth
            selectedLabelView.mask?.frame = frame
            panView.frame = frame
            setDividersVisible(i, max(0.0, min(percentage, 1.0)))
        case .ended, .cancelled:
            animatedTransition = true
            let constant = panView.frame.origin.x + panView.frame.size.width/2
            selectedSegmentIndex = index(for: constant, velocity: velocity.x)
        default:
            break
        }
    }
    
    // MARK: - Accessors
    
    private func newDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = dividerColor
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight, .flexibleTopMargin]
        return view
    }
    
    private func selectedViewFrame(with constant: CGFloat) -> CGRect {
        return CGRect(x: constant,
                      y: SegmentedControl.inset,
                      width: segmentWidth - SegmentedControl.inset*2,
                      height: bounds.size.height - SegmentedControl.inset*2)
    }

    private func index(for locationX: CGFloat, velocity: CGFloat = 0.0) -> Int {
        var calculatedIndex = Int(floor(locationX / segmentWidth))
        if selectedSegmentIndex == calculatedIndex {
            if velocity < -500.0 { calculatedIndex -= 1 }
            else if velocity > 500.0 { calculatedIndex += 1 }
        }
        return max(0, min(calculatedIndex, numberOfSegments-1))
    }
    
    private var segmentWidth: CGFloat {
        guard numberOfSegments > 0 else { return bounds.size.width }
        return bounds.size.width * (1.0 / CGFloat(numberOfSegments))
    }
    
    // MARK: - Properties
    
    private lazy var panView: UIView = {
        let view = UIView()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight, .flexibleTopMargin]
        view.addGestureRecognizer(pan)
        view.backgroundColor = self.selectedSegmentTintColor
        view.layer.cornerRadius = .smallCornerRadius
        view.addShortShadow()

        return view
    }()
    
    private lazy var selectedLabelView: LabelView = {
        let maskView = UIView(frame: .zero)
        maskView.backgroundColor = .black
        maskView.layer.cornerRadius = .smallCornerRadius
        maskView.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight, .flexibleTopMargin]

        let view = LabelView()
        view.backgroundColor = self.selectedSegmentTintColor
        view.mask = maskView
        view.isUserInteractionEnabled = false
        view.typography = .medium(.strong)

        return view
    }()

    private lazy var labelView: LabelView = {
        let view = LabelView()
        view.backgroundColor = .background(.detail)
        view.layer.cornerRadius = .smallCornerRadius
        view.clipsToBounds = true
        return view
    }()
}

private class LabelView: UIView {
    
    var strings = [String]() { didSet { setNeedsDisplay() }}
    var typography: Typography = .medium { didSet { setNeedsDisplay() }}
    var textColor: UIColor = Typography.medium.defaultColor { didSet { setNeedsDisplay() }}

    var attributes: [NSAttributedString.Key: AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = typography.lineHeight - typography.font.lineHeight
        paragraphStyle.alignment = .center
        return [.font: typography.font, .foregroundColor: textColor, .paragraphStyle: paragraphStyle]
    }
    
    override func draw(_ rect: CGRect) { // TODO: add kern etc to Typography and get attributed string from that
        super.draw(rect)
        backgroundColor?.setFill()
        UIRectFill(rect)
        let segmentSize = rect.size.width / CGFloat(strings.count)
        for i in 0..<strings.count {
            let attributedString = NSAttributedString(string: strings[i], attributes: attributes)
            attributedString.draw(in: CGRect(x: segmentSize * CGFloat(i),
                                             y: rect.size.height/2 - typography.lineHeight/2,
                                             width: segmentSize,
                                             height: typography.lineHeight))
        }
    }
}
