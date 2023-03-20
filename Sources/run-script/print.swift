//
//  print.swift
//  
//
//  Created by p-x9 on 2023/03/20.
//

import Foundation

@inline(never)
func print(_ items: Any..., separator: String = " ", terminator: String = "\n", flush: Bool) {
    Swift.print(items, separator: separator, terminator: terminator)
    if flush {
        fflush(stdout)
    }
}
