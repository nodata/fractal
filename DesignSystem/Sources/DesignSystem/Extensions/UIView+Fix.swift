//
//  UIView+Fix.swift
//  DesignSystem
//
//  Created by anthony on 30/09/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation

protocol Fixable {

}

extension UIView: Fixable {

    // MARK: - Fixing Functions

    public func fix(to view: UIView? = nil) {

    }

    public func fix(_ fixtures: [Fixture]) {

        let filteredFixtures = fixtures.filter { !$0.type.needsView }
        if filteredFixtures.count < fixtures.count {
            FixAssert("\(String(describing: self)) - func fix(_ fixtures: [Pin]) is a function for pinning non view constants only, please use func fix(to view: UIView...")
        }
    }

    public var fixtures: [Fixture] {
        return []
    }

    public var activeFixtures: (Fixture?, Fixture?, Fixture?, Fixture?) {
        return (x: nil, y: nil, w: nil, h: nil)
    }

    public func fixtures(for type: Fixture.LayoutType) -> [Fixture] {
        return fixtures.filter { $0.type == type }
    }

    public func fixture(for key: String) -> [Fixture] {
        return fixtures.filter { $0.key == key }
    }

    private func refreshFixtures() {
        for fixture in fixtures {
            guard fixture.type.attribute != .notAnAttribute else { continue }
            if fixture.type.needsView { guard fixture.view != nil else { continue } }
        }
    }
}

extension Array where Element == Fixture {

    // It's a little messy to have both static variables and static functions
    // but it means users can remove empty brackets and it's easier to read an array of fixtures

    public var leading: [Fixture] { return leading() }

    public func fix(to view: UIView? = nil) -> [Fixture] {

        // Add fixer and black starting Fixture to MapTable




        myView.fix(to: self)
                .leading(0.0)
                .top(0.0)
                .width
                .height


      //  myView.fixtures = fix(to: someOtherView).width(-100.0).height(-100.0)


        myView.fix(to: someView, [.leading(0.0),
                                  .top(0.0)])
        myView.fix(to: someOtherView).width(asConstant: 100.0).height(-100.0)

    }


    public func leading(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.leading, view: nil, constant: constant, options: options))
        return new
    }

    private var fixer: Fixer {
        
    }

//    public func trailing(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> Fixer {
//        return Fixture(.trailing, view: view, constant: constant, options: options)
//    }
//
//    public func top(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> Fixer {
//        return Fixture(.top, view: view, constant: constant, options: options)
//    }
//
//    public func bottom(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> Fixer {
//        return Fixture(.bottom, view: view, constant: constant, options: options)
//    }
}

fileprivate class Fixer {

    fileprivate let view: UIView?

    init(view: UIView?) {
        self.view = view
    }
}

public class Fixture {

    public enum Option {
        case multiplier(CGFloat), relation(NSLayoutConstraint.Relation), priority(UILayoutPriority), isActive(Bool), key(String)
    }

    // MARK: - Initialisation

    fileprivate let type: LayoutType
    public var view: UIView?
    public var key: String?
    public var constant: CGFloat
    public var multiplier: CGFloat
    public var relation: NSLayoutConstraint.Relation
    public var priority: UILayoutPriority
    public var isActive: Bool

    fileprivate init(_ type: LayoutType, view: UIView?, constant: CGFloat = 0.0, options: [Option] = []) {

        self.view = view
        self.type = type
        self.constant = constant
        self.multiplier = 1.0
        self.relation = .equal
        self.priority = .almostRequired
        self.isActive = true

        // If you add an option twice, the last value will be used
        for option in options {
            switch option {
            case .multiplier(let value):
                multiplier = value
            case .priority(let value):
                priority = value
            case .relation(let value):
                relation = value
            case .isActive(let value):
                isActive = value
            case .key(let value):
                key = value
            }
        }
    }

    public enum LayoutType: Equatable {

        // Base

        case left
        case right
        case top
        case bottom
        case leading
        case trailing
        case width(Bool)
        case height(Bool)
        case centerX
        case centerY
        case lastBaseline
        case firstBaseline
        case leftMargin
        case rightMargin
        case topMargin
        case bottomMargin
        case leadingMargin
        case trailingMargin
        case centerXWithinMargins
        case centerYWithinMargins
        case none

        // Extended

        case below
        case above
        case leftOf
        case rightOf

        case heightToWidth
        case widthToHeight

        case custom(NSLayoutConstraint.Attribute, NSLayoutConstraint.Attribute)

        case bottomToCenterY
        case topToCenterY
        case centerXToLeading
        case centerXToTrailing
        case centerYToTop
        case centerYToBottom

        var attribute: NSLayoutConstraint.Attribute {

            switch self {
            case .left:
                return .left
            case .right:
                return .right
            case .top:
                return .top
            case .bottom:
                return .bottom
            case .leading:
                return .leading
            case .trailing:
                return .trailing
            case .width:
                return .width
            case .height:
                return .height
            case .centerX:
                return .centerX
            case .centerY:
                return .centerY
            case .lastBaseline:
                return .lastBaseline
            case .firstBaseline:
                return .firstBaseline
            case .leftMargin:
                return .leftMargin
            case .rightMargin:
                return .rightMargin
            case .topMargin:
                return .topMargin
            case .bottomMargin:
                return .bottomMargin
            case .leadingMargin:
                return .leadingMargin
            case .trailingMargin:
                return .trailingMargin
            case .centerXWithinMargins:
                return .centerXWithinMargins
            case .centerYWithinMargins:
                return .centerYWithinMargins
            case .none:
                return .notAnAttribute

            case .below:
                return .top
            case .above:
                return .bottom
            case .leftOf:
                return .right
            case .rightOf:
                return .left
            case .heightToWidth:
                return .height
            case .widthToHeight:
                return .width
            case .bottomToCenterY:
                return .bottom
            case .topToCenterY:
                return .top
            case .centerXToLeading:
                return .centerX
            case .centerXToTrailing:
                return .centerX
            case .centerYToTop:
                return .centerY
            case .centerYToBottom:
                return .centerY

            case .custom(let value, _):
                return value
            }
        }

        var toAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .below:
                return .bottom
            case .above:
                return .top
            case .leftOf:
                return .left
            case .rightOf:
                return .right
            case .heightToWidth:
                return .width
            case .widthToHeight:
                return .height
            case .bottomToCenterY:
                return .centerY
            case .topToCenterY:
                return .centerY
            case .centerXToLeading:
                return .leading
            case .centerXToTrailing:
                return .trailing
            case .centerYToTop:
                return .top
            case .centerYToBottom:
                return .bottom
            case .width(let constant), .height(let constant):
                return constant ? .notAnAttribute : attribute
            case .custom(_, let value):
                return value
            default:
                return attribute
            }
        }

        var needsView: Bool {
            switch self {
            case .width, .height:
                return false
            default:
                return true
            }
        }

        var ignoreView: Bool {
            switch self {
            case .width(let constant), .height(let constant):
                return constant
            default:
                return false
            }
        }
    }



}

private func FixAssert(_ message: String = "") {
    #if DEBUG
    print("FixAssert:", message)
    fatalError()
    #endif
}
