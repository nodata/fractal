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
    
    private class ClosureWrapper<V>: NSObject {

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
    }
    
    public func removeObserver(_ object: AnyObject) {
        let wrapper = observers.object(forKey: object)
        if let wrappers = objc_getAssociatedObject(object, &AssociatedKeys.reference) as? [NSObject] {
            objc_setAssociatedObject(object, &AssociatedKeys.reference, wrappers.filter { $0 != wrapper }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        observers.removeObject(forKey: object)
    }
    
    private func notify() {
        let enumerator = observers.objectEnumerator()
        while let wrapper = enumerator?.nextObject() { (wrapper as? ClosureWrapper<V>)?.closure(value) }
    }
}

private struct AssociatedKeys {
    static var reference = "reference"
}
