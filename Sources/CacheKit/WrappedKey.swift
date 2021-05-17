//
//  File.swift
//  
//
//  Created by BJ Beecher on 5/17/21.
//

import Foundation

final class WrappedKey<Key: Hashable>: NSObject {
    let key: Key
    
    init(_ key: Key) {
        self.key = key
    }
    
    override var hash : Int {
        key.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let value = object as? WrappedKey {
            return value.key == key
        } else {
            return false
        }
    }
}
