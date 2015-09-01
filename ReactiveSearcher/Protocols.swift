//
//  Protocols.swift
//  ReactiveSearcher
//
//  Created by Murillo Nicacio de Maraes on 6/16/15.
//  Copyright (c) 2015 SuperUnreasonable. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol ReactiveSearcher {
    typealias SearchKeyType
    typealias SearchResultType
    typealias SearchErrorType: ErrorType

    var searcherResults: Signal<(SearchKeyType, [SearchResultType]), NoError> { get }
    var searcherErrors: Signal<SearchErrorType, NoError> { get }

    func search(key: SearchKeyType)
}

public protocol ReactiveCache {
    typealias CacheKeyType: Hashable
    typealias CacheStoredType

    //MARK: Storage Signals
    var updateSignal: Signal<CacheUpdate<CacheKeyType, CacheStoredType>, NoError> { get }
    var valueSignal: Signal<[CacheKeyType: CacheStoredType], NoError> { get }

    //MARK: Query Result Signals
    /// Signal that reports the results of query searches.
    var querySignal: Signal<(CacheKeyType, CacheStoredType?), NoError> { get }

    //Probably Derived from querySignal. Might be better implemented as Protocol Extension Swift 2+
    var hitSignal: Signal<(CacheKeyType, CacheStoredType), NoError> { get }
    var missSignal: Signal<CacheKeyType, NoError> { get }

    func query(key: CacheKeyType)
    func updateValue(value: CacheStoredType, forKey key: CacheKeyType)
    func invalidateValueForKey(key: CacheKeyType)
    func invalidateCache()
}