//
//  File.swift
//  
//
//  Created by BJ Beecher on 5/17/21.
//

import Foundation

final class Entry<Key, Value> {
    let key : Key
    let value : Value

    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}

extension Entry : Codable where Key : Codable, Value : Codable {}
