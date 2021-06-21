//
//  ConsoleIO.swift
//  Panagram
//
//  Created by Peter Wu on 6/14/21.
//

import Foundation

class ConsoleIO {
    
    var standardError = StandardErrorOutput()
    
    enum OutputType {
        case error
        case standard
    }
    // TODO: use FileHandle instead of Darwin
    
    /// This method prints messages to console or standard error stream, depending
    /// on the output type
    /// - Parameters:
    ///   - message: The message to print to the console
    ///   - to: The output type - standard or error
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\u{001B}[;m\(message)") // writes to stdout by default
        case .error:
            print("\(message)", to: &standardError)
        }
    }
    
    func getInput() -> String {
        return readLine(strippingNewline: true)!
    }
}

struct StandardErrorOutput: TextOutputStream {
    public func write(_ string: String) {
        fputs("\u{001B}[0;31m\(string)", stderr) // output to standard error
    }
}
