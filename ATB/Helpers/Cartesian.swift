//
//  Cartesian.swift
//  ATB
//
//  Created by YueXi on 2/16/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import Foundation

func + <T>(el: T, arr: [T]) -> [T] {
    var ret = arr

    ret.insert(el, at: 0)

    return ret
}

func cartesianProduct<T>(_ arrays: [[T]]) -> [[T]] {
    guard let head = arrays.first else { return [] }

    let first = Array(head)

    func pel(_ el: T, _ ll: [[T]], _ a: [[T]] = []) -> [[T]] {
    switch ll.count {
        case 0:
          return a.reversed()
        case _:
          let tail = Array(ll.dropFirst())
          let head = ll.first!

          return pel(el, tail, el + head + a)
        }
    }

    return arrays.reversed()
        .reduce([first], {res, el in el.flatMap({ pel($0, res) }) })
        .map({ $0.dropLast(first.count) })
}
