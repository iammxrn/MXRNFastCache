//
//  MXRNFastCacheKeyImpl.swift
//  MXRNFastCache
//
//  Created by Roman Mogutnov on 8/1/22.
//

import Foundation

protocol MXRNFastCacheKey: Hashable, NSObjectProtocol {

    associatedtype Key: Hashable

    var key: Key { get }

}

final class MXRNFastCacheKeyImpl<Key: Hashable>: NSObject, MXRNFastCacheKey {
    
    
    // MARK: - Internal Properties
    
    let key: Key
    
    override var hash: Int {
        return key.hashValue
    }
    
    
    // MARK: - Init
    
    init(_ key: Key) {
        self.key = key
    }
    
    
    // MARK: - Internal Methods
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let value = object as? MXRNFastCacheKeyImpl else { return false }
        
        return value.key == key
    }
    
}


// MARK: - Codable Support

extension MXRNFastCacheKeyImpl: Codable where Key: Codable {}
