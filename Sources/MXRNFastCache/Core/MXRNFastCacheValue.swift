//
//  MXRNFastCacheValue.swift
//  MXRNFastCache
//
//  Created by Roman Mogutnov on 8/1/22.
//

import Foundation

protocol MXRNFastCacheValue {
    
    associatedtype Key: Hashable
    associatedtype Value
    
    var key: Key { get }
    
    var value: Value { get }
    
}


// MARK: - Implementation

final class MXRNFastCacheValueImpl<Key: Hashable, Value>: MXRNFastCacheValue {
    
    
    // MARK: - Internal Properties
    
    let key: Key
    
    let value: Value
    
    let expirationDate: Date
    
    
    // MARK: - Init
    
    init(
        key: Key,
        value: Value,
        expirationDate: Date
    ) {
        self.key = key
        self.value = value
        self.expirationDate = expirationDate
    }
}


// MARK: - Codable Support

extension MXRNFastCacheValueImpl: Codable where Key: Codable, Value: Codable {}
