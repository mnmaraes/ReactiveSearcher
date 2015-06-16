//
//  ReactiveCocoa+Extensions.swift
//  ReactiveSearcher
//
//  Created by Murillo Nicacio de Maraes on 6/16/15.
//  Copyright (c) 2015 SuperUnreasonable. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import Box

/// Useful for Transforming Error Events into Next Events.
func mapResult<T, U, E: ErrorType>(transform: Result<T, E> -> U)(signal: Signal<T, E>) -> Signal<U, NoError> {
    return signal
        |> materialize
        |> map { (event: Event<T, E>) -> Event<U, NoError> in
            switch event {
            case .Next(let box):
                return .Next(box.map { transform(Result(value: $0)) })
            case .Error(let box):
                return .Next(box.map { transform(Result(error: $0)) })
            case .Completed:
                return .Completed
            case .Interrupted:
                return .Interrupted
            }
        }
        |> dematerialize
}

/// Zips Signals together but only sends updates when `signal` does
func combineSampled<T, U, E: ErrorType>(signal: Signal<T, E>)(original: Signal<U, E>) -> Signal<(U, T), E> {
    return Signal { sink in
        let property = MutableProperty<T?>(nil)

        let signalDisposable = property <~ signal |> mapResult { $0.value } |> ignoreNil

        let originalDisposable = original
            |> map { ($0, property.value) }
            |> filter { $1 != nil }
            |> map { ($0, $1!) }
            |> observe(sink)

        let composite = CompositeDisposable([signalDisposable])

        if let originalDisposable = originalDisposable {
            composite.addDisposable(originalDisposable)
        }

        return composite
    }
}