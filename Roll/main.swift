//
//  main.swift
//  Roll
//
//  Created by Peter Wu on 6/21/21.
//

import Foundation

let roll = Roll()

if CommandLine.argc < 2 {
    roll.interactiveMode()
} else {
    roll.staticMode()
}
