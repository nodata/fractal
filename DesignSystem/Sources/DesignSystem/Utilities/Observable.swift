//
//  Observed.swift
//  DesignSystem
//
//  Created by herbal7ea on 8/21/19.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation

// While reactive frameworks do the same job, keeping this framework dependency free is the goal..
// Using this helper is completely optional, using reactive a framework to make Sections is of course possible

open class Observable<V> {
    
    private class ClosureWrapper<V> {
        var closure: (V) -> Void
        public init(_ closure: @escaping (V) -> Void) {
            self.closure = closure
        }
    }
    
    public var value: V { didSet { notify() } }
    
    // NSMapTable for this purpose is essentially a dictionary with the ability to hold objects weakly or strongly...
    // Meaning in this case we can let numerous objects observe our value and be removed automatically on deinit
    private var observers = NSMapTable<AnyObject, ClosureWrapper<V>>(keyOptions: [.weakMemory], valueOptions: [.weakMemory])
    
    public init(_ initital: V) {
        value = initital
    }
    
    public func addObserver(_ observingObject: AnyObject, skipFirst: Bool = true, closure: @escaping (V) -> Void) {
        
        let wrapper = ClosureWrapper(closure)
        
        // Giving the closure back to the object that is observing allows ClosureWrapper to die at the same time as observing object
        
        var wrappers = objc_getAssociatedObject(observingObject, &AssociatedKeys.reference) as? [Any] ?? [Any]()
        wrappers.append(wrapper)
        objc_setAssociatedObject(observingObject, &AssociatedKeys.reference, wrappers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        observers.setObject(wrapper, forKey: observingObject)
        if !skipFirst { closure(value) }
        
//        var didSet = false
//
//        for s in references {
//            var string = s
//            if objc_getAssociatedObject(observingObject, &string) == nil {
//                objc_setAssociatedObject(observingObject, &string, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                observers.setObject(wrapper, forKey: observingObject)
//                if !skipFirst { closure(value) }
//                didSet = true
//                break
//            }
//        }
//
//        if !didSet {
//            print("Maximum number of observers \(references.count) reached for \(observingObject)")
//        }
    }
    
    public func removeObserver(_ object: AnyObject) {
        // TODO: needs to search the array in the associated object now
        observers.removeObject(forKey: object)
    }
    
    private func notify() {
        let enumerator = observers.objectEnumerator()
        while let wrapper = enumerator?.nextObject() { (wrapper as? ClosureWrapper<V>)?.closure(value) }
    }
    
//    private lazy var references: [String] = {
//        let array = [AssociatedKeys.reference1,
//                     AssociatedKeys.reference2,
//                     AssociatedKeys.reference3,
//                     AssociatedKeys.reference4,
//                     AssociatedKeys.reference5,
//                     AssociatedKeys.reference6,
//                     AssociatedKeys.reference7,
//                     AssociatedKeys.reference8,
//                     AssociatedKeys.reference9,
//                     AssociatedKeys.reference10]
//        return array
//    }()
}

private struct AssociatedKeys {
    static var reference = "reference"
//    static var reference1 = "reference1"
//    static var reference2 = "reference2"
//    static var reference3 = "reference3"
//    static var reference4 = "reference4"
//    static var reference5 = "reference5"
//    static var reference6 = "reference6"
//    static var reference7 = "reference7"
//    static var reference8 = "reference8"
//    static var reference9 = "reference9"
//    static var reference10 = "reference10"
}
