//
//  FallbackCache.swift
//  ReactiveSearcher
//
//  Created by Murillo Nicacio de Maraes on 7/10/15.
//  Copyright (c) 2015 SuperUnreasonable. All rights reserved.
//

import Foundation
import ReactiveCocoa

/* Would be Cache misses create new values instead.
*
* Would be misses are still reported by querySignal and missSignal.
*/
public struct FallbackCache<Key: Hashable, Value>: ReactiveCache {
    private let innerCache: Cache<Key, Value>

    public var updateSignal: Signal<CacheUpdate<Key, Value>, NoError> { return innerCache.updateSignal }
    public var valueSignal: Signal<[Key: Value], NoError> { return innerCache.valueSignal }

    public var querySignal: Signal<(Key, Value?), NoError> { return innerCache.querySignal }

    public let hitSignal: Signal<(Key, Value), NoError>
    public var missSignal: Signal<Key, NoError> { return innerCache.missSignal }

    public init(_ fallback: Key -> Value) {
        let innerCache = Cache<Key, Value>()

        innerCache.missSignal
            |> observe(next: { key in
                innerCache.updateValue(fallback(key), forKey: key)
            })

        self.innerCache = innerCache
        self.hitSignal = Signal { sink in
            innerCache.hitSignal |> observe(sink)
            innerCache.missSignal |> map { ($0, fallback($0)) } |> observe(sink)

            return nil
        }
    }

    public func query(key: Key) {
        innerCache.query(key)
    }

    public func updateValue(value: Value, forKey key: Key) {
        innerCache.updateValue(value, forKey: key)
    }

    public func invalidateValueForKey(key: Key) {
        innerCache.invalidateValueForKey(key)
    }

    public func invalidateCache() {
        innerCache.invalidateCache()
    }
}