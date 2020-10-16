//
//  Helpers.swift
//  DesignSystem
//
//  Created by anthony on 15/02/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation
import UIKit

public let isIPad = UIDevice.current.userInterfaceIdiom == .pad

func Assert(_ message: String = "") {
    #if DEBUG
    print("Assert:", message)
    fatalError()
    #endif
}

public extension MutableCollection {
    subscript (safe index: Index) -> Iterator.Element? {
        get {
            guard startIndex <= index && index < endIndex else { return nil }
            return self[index]
        }
        set(newValue) {
            guard startIndex <= index && index < endIndex else { print("Index out of range."); return }
            guard let newValue = newValue else { print("Cannot remove out of bounds items"); return }
            self[index] = newValue
        }
    }
}

public extension Sequence where Element: Hashable {
    var unique: [Element] {
        NSOrderedSet(array: self as! [Any]).array as! [Element]
    }
}

public extension Array where Element: Equatable {
    mutating func remove(_ object: Element) {
        guard let index = self.firstIndex(of: object) else { return }
        self.remove(at: index)
    }
}

public extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views { addSubview(view) }
    }
}

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

public extension UIScrollView {
    var isBeingManipulated: Bool {
        return isDragging || isZooming || isTracking || isDecelerating
    }
}

public extension UIView {

    func findShallowestInHierarchy<V, B>(_ type1: V.Type, _ type2: B.Type) -> (V?, B?) {
        var v: UIView? = superview
        while !(v is V) && !(v is B) && v != nil { v = v?.superview }
        return (v as? V, v as? B)
    }

    func findInHierarchy<V>(_ type: V.Type) -> V? {
        var v: UIView? = superview
        while !(v is V) && v != nil { v = v?.superview }
        return v as? V
    }
}

public extension Array {
    func wrappedIndex(_ value: Int) -> Int {
        var index = value
        while index > count-1 { index -= count }
        while index < 0 { index += count }
        return index
    }
}

public extension UIScreen {
    
    enum Device {
        case unknown,
        iPhone12, iPhone12Max, iPhoneX, iPhone8Plus, iPhone8, iPhoneSE,
        iPadPro12, iPadPro10, iPad
    }
    
    var device: Device {
        
        let size = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                          height: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
     
        switch (size.width, size.height) {
        case (428, 926):
            return .iPhone12Max
        case (390, 844):
            return .iPhone12
        case (375, 812):
            return .iPhoneX
        case (414, 736):
            return .iPhone8Plus
        case (375, 667):
            return .iPhone8
        case (320, 568):
            return .iPhoneSE
            
        case (1024, 1336):
            return .iPadPro12
        case (834, 1112):
            return .iPadPro10
        case (768, 1024):
            return .iPad
        default:
            return .unknown
        }
    }
}
