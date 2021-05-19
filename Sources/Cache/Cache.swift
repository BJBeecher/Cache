//
//  Cache.swift
//  Luna
//
//  Created by BJ Beecher on 10/3/20.
//  Copyright © 2020 Renaissance Technologies. All rights reserved.
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    typealias SetValue = (Entry<Value>, WrappedKey<Key>) -> Void
    typealias GetValue = (WrappedKey<Key>) -> Entry<Value>?
    typealias RemoveValue = (WrappedKey<Key>) -> Void
    
    let setValue : SetValue
    let getValue : GetValue
    let removeValue : RemoveValue
    
    init(setValue: @escaping SetValue, getValue: @escaping GetValue, removeValue: @escaping RemoveValue) {
        self.setValue = setValue
        self.getValue = getValue
        self.removeValue = removeValue
    }
    
    public convenience init() {
        let store = NSCache<WrappedKey<Key>, Entry<Value>>()
        
        self.init(setValue: store.setObject, getValue: store.object, removeValue: store.removeObject)
    }
}

// API

extension Cache {
    public func insert(_ value: Value, forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        let entry = Entry(value: value)
        
        setValue(entry, wrappedKey)
    }

    public func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        let entry = getValue(wrappedKey)
        let value = entry?.value
        
        return value
    }

    public func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        
        removeValue(wrappedKey)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            value(forKey: key)
        }
        set {
            if let value = newValue {
                insert(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
}
