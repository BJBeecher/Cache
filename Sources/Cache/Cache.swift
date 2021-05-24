//
//  Cache.swift
//  Luna
//
//  Created by BJ Beecher on 10/3/20.
//  Copyright © 2020 Renaissance Technologies. All rights reserved.
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    typealias SetValue = (Entry<Key, Value>, WrappedKey<Key>) -> Void
    typealias GetValue = (WrappedKey<Key>) -> Entry<Key, Value>?
    typealias RemoveValue = (WrappedKey<Key>) -> Void
    
    let setValue : SetValue
    let getValue : GetValue
    let removeValue : RemoveValue
    
    let keyTracker = KeyTracker<Key, Value>()
    
    init(setValue: @escaping SetValue, getValue: @escaping GetValue, removeValue: @escaping RemoveValue) {
        self.setValue = setValue
        self.getValue = getValue
        self.removeValue = removeValue
    }
    
    public convenience init() {
        let store = NSCache<WrappedKey<Key>, Entry<Key, Value>>()
        self.init(setValue: store.setObject, getValue: store.object, removeValue: store.removeObject)
        store.delegate = keyTracker
    }
}

// API

extension Cache {
    public func insert(_ value: Value, forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        let entry = Entry(key: key, value: value)
        setValue(entry, wrappedKey)
        keyTracker.keys.insert(key)
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

// internal API

extension Cache {
    func entry(forKey key: Key) -> Entry<Key, Value>? {
        if let entry = getValue(WrappedKey(key)) {
            return entry
        } else {
            return nil
        }
    }
    
    func insert(_ entry: Entry<Key, Value>) {
        setValue(entry, WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

// codable

extension Cache : Codable where Key : Codable, Value : Codable {
    convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry<Key, Value>].self)
        entries.forEach(insert)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
    
    public func saveToDisk(withName name: String, fileManager: FileManager = .default, encoder: JSONEncoder = .init()) throws {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try encoder.encode(self)
        try data.write(to: fileURL)
    }
    
    public static func loadFromDisk(withName name: String, fileManager: FileManager = .default, decoder: JSONDecoder = .init()) throws -> Cache<Key, Value> {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try Data(contentsOf: fileURL)
        let cache = try decoder.decode(Cache.self, from: data)
        return cache
    }
}
