//
//  TwoButtonView.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 11/4/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import Foundation
import DesignSystem

public class TwoButtonView: UIView {

    private let style1: Button.Style
    private let style2: Button.Style
    private var closure1: VoidClosure = { }
    private var closure2: VoidClosure = { }

    public init(style1: Button.Style, style2: Button.Style, buttonWidth: CGFloat, padding: CGFloat) {
        self.style1 = style1
        self.style2 = style2
        super.init(frame: .zero)
        guard let buttonBrand = BrandingManager.brand as? ButtonBrand else { Assert("BrandingManager.brand does not conform to ButtonBrand"); return }
        
        addSubview(button1)
        addSubview(button2)
        
        let size = Button.Size(width: .half, height: .large)
        
        let offset = buttonWidth/2 + padding/2
        
        button1.pin(to: self, [.top(.xxsmall), .centerX(-offset),  .width(asConstant: 164), buttonBrand.heightPin(for: size)])
        button2.pin(to: self, [.top(.xxsmall), .centerX(offset), .width(asConstant: 164), buttonBrand.heightPin(for: size)])
        // Potentially change this widthPin / heightPin setup
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(buttonTitle1: String, buttonTitle2: String, closure1:@escaping VoidClosure, closure2:@escaping VoidClosure) {
        button1.setTitle(buttonTitle1, for: .normal)
        button2.setTitle(buttonTitle2, for: .normal)
        self.closure1 = closure1
        self.closure2 = closure2
    }

    @objc private func tapped(_ sender: Button) {
        print("sender.tag: \(sender.tag)")
        if sender.tag == 1 {
            closure1()
        } else {
            closure2()
        }
    }

    // MARK: - Properties
    public lazy var button1: Button = {
        let button = Button(style: self.style1)
            button.tag = 1
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()

    public lazy var button2: Button = {
        let button = Button(style: self.style2)
            button.tag = 2
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()
}
