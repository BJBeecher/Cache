//
//  File.swift
//  
//
//  Created by BJ Beecher on 5/24/21.
//

import Foundation

final class KeyTracker<Key: Hashable, Value>: NSObject, NSCacheDelegate {
    var keys = Set<Key>()
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
        guard let entry = object as? Entry<Key, Value> else { return }
        keys.remove(entry.key)
    }
}
