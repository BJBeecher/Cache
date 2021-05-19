import XCTest
@testable import Cache

final class CacheTests: XCTestCase {
    
    var store = [WrappedKey<UUID> : Entry<String>]()
    
    lazy var cache = Cache<UUID, String> { entry, wrappedKey in
        self.store[wrappedKey] = entry
    } getValue: { wrappedKey in
        self.store[wrappedKey]
    } removeValue: { wrappedKey in
        self.store.removeValue(forKey: wrappedKey)
    }

    
    let key = UUID()
    let value = "Tommy"
    
    func testInsert(){
        cache.insert(value, forKey: key)
        
        assert(store[.init(key)]?.value == value)
    }
    
    func testGet(){
        cache.insert(value, forKey: key)
        let returned = cache.value(forKey: key)
        assert(returned == value)
    }
    
    func testDelete(){
        cache.removeValue(forKey: key)
        
        assert(store[.init(key)] == nil)
    }
}
