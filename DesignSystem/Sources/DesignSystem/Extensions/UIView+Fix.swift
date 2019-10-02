//
//  UIView+Fix.swift
//  DesignSystem
//
//  Created by anthony on 30/09/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation

extension UIView {

    public func fix(_ fixtures: [Fixture]) {

        let filteredFixtures = fixtures.filter { !$0.type.needsView }
        if filteredFixtures.count < fixtures.count {
            FixAssert("\(String(describing: self)) - func fix(_ fixtures: [Pin]) is a function for pinning non view constants only, please use func fix(to view: UIView...")
        }
    }

    public var fixtures: [Fixture] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.fixtures) as? [Fixture] ?? []
        }

        set {
            objc_setAssociatedObject(self, &AssociatedKeys.fixtures, newValue.filter { !$0.isDisposable }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            refreshFixtures()
        }
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

    fileprivate func refreshFixtures() {
        autoresizingMask = [.flexibleWidth,
                            .flexibleHeight,
                            .flexibleTopMargin,
                            .flexibleBottomMargin,
                            .flexibleRightMargin,
                            .flexibleRightMargin]

        var newFrame: CGRect = .zero

        for fixture in fixtures {
            guard fixture.type.attribute != .notAnAttribute else { continue }
            if fixture.type.needsView { guard fixture.view != nil else { continue } }

            if fixture.type == .leading {
                newFrame.origin.x = (fixture.view?.bounds.minX ?? 0.0) + fixture.constant
            }
        }
    }
}

extension Array where Element == Fixture {

    public static func fix(to view: UIView? = nil) -> [Fixture] {
        let initial = Fixture(.none, isDisposable: true, view: view, constant: 0.0, options: [])
        return [initial]
    }

    private var view: UIView? { return first?.view }

    // It's a little messy to have both static variables and static functions
    // but it means users can remove empty brackets and it's easier to read an array of fixtures

    public var leading:  [Fixture] { return leading() }
    public var trailing: [Fixture] { return trailing() }
    public var top:      [Fixture] { return top() }
    public var bottom:   [Fixture] { return bottom() }
    public var width:    [Fixture] { return width() }
    public var height:   [Fixture] { return height() }

    public func leading(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.leading, view: view, constant: constant, options: options))
        return new
    }

    public func trailing(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.trailing, view: view, constant: constant, options: options))
        return new
    }

    public func top(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.top, view: view, constant: constant, options: options))
        return new
    }

    public func bottom(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.bottom, view: view, constant: constant, options: options))
        return new
    }

    public func width(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.width(view == nil), view: view, constant: constant, options: options))
        return new
    }

    public func height(_ constant: CGFloat = 0.0, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.height(view == nil), view: view, constant: constant, options: options))
        return new
    }

    public func width(asConstant: CGFloat, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.width(true), view: nil, constant: asConstant, options: options))
        return new
    }

    public func height(asConstant: CGFloat, options: [Fixture.Option] = []) -> [Fixture] {
        var new = self
        new.append(Fixture(.height(true), view: nil, constant: asConstant, options: options))
        return new
    }
}

public class Fixture {

    public enum Option {
        case multiplier(CGFloat), relation(NSLayoutConstraint.Relation), priority(UILayoutPriority), isActive(Bool), key(String)
    }

    // MARK: - Initialisation

    fileprivate let type: LayoutType
    fileprivate let isDisposable: Bool
    public weak var view: UIView?
    public var key: String?
    public var constant: CGFloat
    public var multiplier: CGFloat
    public var relation: NSLayoutConstraint.Relation
    public var priority: UILayoutPriority
    public var isActive: Bool

    fileprivate init(_ type: LayoutType, isDisposable: Bool = false, view: UIView?, constant: CGFloat = 0.0, options: [Option] = []) {

        self.isDisposable = isDisposable
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

private struct AssociatedKeys {
    static var fixtures = "FixableFixtures"
}

private func FixAssert(_ message: String = "") {
    #if DEBUG
    print("FixAssert:", message)
    fatalError()
    #endif
}
