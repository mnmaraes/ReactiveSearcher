//
//  Extension.swift
//  Hi
//
//  Created by Murillo Nicacio de Maraes on 6/13/15.
//  Copyright (c) 2015 HappeningIn. All rights reserved.
//

import Foundation

extension Dictionary {
    func associate(key: Key, value: Value) -> Dictionary {
        var copy = self

        copy[key] = value

        return copy
    }

    func dissociate(key: Key) -> Dictionary {
        var copy = self

        copy.removeValueForKey(key)

        return copy
    }
}
