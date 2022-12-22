//
//  MXRNCacheKeyTracker.swift
//  MXRNFastCache
//
//  Created by Roman Mogutnov on 8/1/22.
//

import Foundation

final class MXRNCacheKeyTracker<Value: MXRNFastCacheValue>: NSObject, NSCacheDelegate {


    // MARK: - Private Properties
    
    private(set) var keys = Set<Value.Key>()


    // MARK: - Internal Methods

    @discardableResult
    func insert(_ newMember: Value.Key) -> (inserted: Bool, memberAfterInsert: Value.Key) {
        keys.insert(newMember)
    }


    // MARK: - NSCacheDelegate

    func cache(
        _ cache: NSCache<AnyObject, AnyObject>,
        willEvictObject object: Any
    ) {
        guard let entry = object as? Value else {
            return
        }

        keys.remove(entry.key)
    }
    
}
