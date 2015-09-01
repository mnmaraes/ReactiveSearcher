//
//  CachedSearcher.swift
//  ReactiveSearcher
//
//  Created by Murillo Nicacio de Maraes on 6/16/15.
//  Copyright (c) 2015 SuperUnreasonable. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct CachedSearcher<SearcherType: ReactiveSearcher, CacheType: ReactiveCache where
    SearcherType.SearchKeyType == CacheType.CacheKeyType,
    CacheType.CacheStoredType == [SearcherType.SearchResultType]>: ReactiveSearcher, ReactiveCache {
    typealias Key = SearcherType.SearchKeyType
    typealias ResultType = SearcherType.SearchResultType
    typealias Error = SearcherType.SearchErrorType

    private let searcher: SearcherType
    private let cache: CacheType

    public let searcherResults: Signal<(Key, [ResultType]), NoError>
    public var searcherErrors: Signal<Error, NoError> { return searcher.searcherErrors }

    public var updateSignal: Signal<CacheUpdate<Key, [ResultType]>, NoError> { return cache.updateSignal }
    public var valueSignal: Signal<[Key: [ResultType]], NoError> { return cache.valueSignal }

    public var querySignal: Signal<(Key, [ResultType]?), NoError> { return cache.querySignal }

    public var hitSignal: Signal<(Key, [ResultType]), NoError> { return cache.hitSignal }
    public var missSignal: Signal<Key, NoError> { return cache.missSignal }

    public init(searcher: SearcherType, cache: CacheType) {
        self.searcher = searcher
        self.cache = cache

        //Search on Cache Misses
        cache.missSignal |> observe(next: { searcher.search($0) })

        //Update Cache on Successful Searches
        searcher.searcherResults |> observe(next: { cache.updateValue($1, forKey: $0) } )

        self.searcherResults = Signal { sink in
            //Send Results on Cache hits and Search Successes
            cache.hitSignal |> observe(sink)
            searcher.searcherResults |> observe(sink)

            return nil
        }
    }

    public func search(key: Key) {
        self.query(key)
    }

    public func query(key: Key) {
        cache.query(key)
    }

    public func updateValue(value: [ResultType], forKey key: Key) {
        cache.updateValue(value, forKey: key)
    }

    public func invalidateValueForKey(key: Key) {
        cache.invalidateValueForKey(key)
    }

    public func invalidateCache() {
        cache.invalidateCache()
    }
}