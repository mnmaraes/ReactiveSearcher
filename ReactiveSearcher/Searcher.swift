//
//  Searcher.swift
//  ReactiveAdventures
//
//  Created by Murillo Nicacio de Maraes on 6/13/15.
//  Copyright (c) 2015 TIL. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct Searcher<Key, ResultType, Error: ErrorType>: ReactiveSearcher {
    private let searchAction: Action<Key, (Key, [ResultType]), Error>

    public var searcherResults: Signal<(Key, [ResultType]), NoError> { return searchAction.values }
    public var searcherErrors: Signal<Error, NoError> { return searchAction.errors }

    public init(searchingFunction: Key -> SignalProducer<[ResultType], Error>) {
        self.searchAction = Action { input in
            return searchingFunction(input)
                |> map { (input, $0) }
        }
    }

    public func search(key: Key) {
        searchAction.apply(key) |> start()
    }
}



