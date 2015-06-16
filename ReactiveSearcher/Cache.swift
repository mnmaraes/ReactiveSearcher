//
//  Cache.swift
//  ReactiveSearcher
//
//  Created by Murillo Nicacio de Maraes on 6/16/15.
//  Copyright (c) 2015 SuperUnreasonable. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Box

public enum CacheUpdate<K, V> {
    case Set(Box<K>, Box<V>)
    case Invalidate(Box<K>)
    case NoOp
}

public enum CacheError {
    case ValueUnavailable
}

public struct Cache<Key: Hashable, Value>: ReactiveCache {
    private let queryAction: Action<Key, Key, NoError>
    private let updateAction: Action<CacheUpdate<Key, Value>, CacheUpdate<Key, Value>, NoError>

    public var updateSignal: Signal<CacheUpdate<Key, Value>, NoError> { return updateAction.values }
    public let querySignal: Signal<(Key, Value?), NoError>
    public let valueSignal: Signal<[Key: Value], NoError>

    public init() {
        self.updateAction = Action { SignalProducer(value: $0) }

        let updateSignal = updateAction.values

        let valueSignal: Signal<[Key: Value], NoError> = updateSignal
            |> scan([:]) {
                switch $1 {
                case .Set(let keyBox, let valueBox):
                    return $0.associate(keyBox.value, value: valueBox.value)
                case .Invalidate(let keyBox):
                    return $0.dissociate(keyBox.value)
                case .NoOp:
                    return $0
                }
            }

        self.queryAction = Action { input in
            return SignalProducer(value: input)
        }

        let querySignal = queryAction.values
            |> combineSampled(valueSignal)
            |> map { ($0, $1[$0]) }

        self.valueSignal = valueSignal
        self.querySignal = querySignal

        querySignal |> observe(next: { println("Query made for \($0) and got \($1)") })

        updateAction.apply(.NoOp) |> start()
    }

    public func query(key: Key) {
        queryAction.apply(key) |> start()
    }

    public func updateValue(value: Value, forKey key: Key) {
        updateAction.apply(.Set(Box(key), Box(value))) |> start()
    }

    public func invalidateValueForKey(key: Key) {
        updateAction.apply(.Invalidate(Box(key))) |> start()
    }
}