//
//  MXRNFastCache.swift
//  MXRNFastCache
//
//  Created by Roman Mogutnov on 7/29/22.
//

import Foundation

public final class MXRNFastCache<Key: Hashable, Value> {


    // MARK: - Typealiases

    fileprivate typealias WrappedKey = MXRNFastCacheKeyImpl<Key>
    fileprivate typealias WrappedValue = MXRNFastCacheValueImpl<Key, Value>


    // MARK: - Private Properties

    private let wrapped = NSCache<WrappedKey, WrappedValue>()

    private let dateProvider: () -> Date

    private let entryLifetime: TimeInterval

    private let keyTracker = MXRNCacheKeyTracker<WrappedValue>()


    // MARK: - Init

    public init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifetime: TimeInterval = 12 * 60 * 60,
        maximumEntryCount: Int = 50
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        self.wrapped.countLimit = maximumEntryCount
        self.wrapped.delegate = keyTracker
    }


    // MARK: - Subscript

    public subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        } set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }


    // MARK: - Public Methods

    public func insert(
        _ value: Value,
        forKey key: Key
    ) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = WrappedValue(
            key: key,
            value: value,
            expirationDate: date
        )
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.insert(key)
    }

    public func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

}


// MARK: - Helper Methods

extension MXRNFastCache {

    fileprivate func entry(forKey key: Key) -> WrappedValue? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    fileprivate func insert(_ entry: WrappedValue) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.insert(entry.key)
    }

}


// MARK: - Codable Support

extension MXRNFastCache: Codable where Key: Codable, Value: Codable {

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([WrappedValue].self)
        entries.forEach(insert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }

}


// MARK: - Persisting

extension MXRNFastCache where Key: Codable, Value: Codable {

    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }

}
