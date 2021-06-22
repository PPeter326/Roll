//
//  Roll.swift
//  Roll
//
//  Created by Peter Wu on 6/21/21.
//

import Foundation

final class Roll {
    
    private enum OptionType: String {
        case `repeat` = "r"
        case help = "h"
        case quit = "q"
        case unknown
        
        init(value: String) {
            switch value {
            case "r":
                self = .repeat
            case "h":
                self = .help
            case "q":
                self = .quit
            default:
                self = .unknown
            }
        }
    }
    
    private struct Dice {
        var pipsLanded: Int = 1
        mutating func roll() {
            pipsLanded = Int.random(in: 1...6)
        }
    }
    
    private enum ErrorType {
        case invalidNumber
        case tooManyArguments
        case tooFewArguments
        case invalidOption
    }
    
    let consoleIO = ConsoleIO()
    
    
    func staticMode() {
        assert(CommandLine.argc >= 2, "Too few arguments for static mode")
        var arguments = CommandLine.arguments
        arguments.removeFirst() // remove program argument
        let optionArgument = arguments.first! // force unwrap because we know there's 2 or more arguments
        // check if an option is present
        if optionArgument.hasPrefix("-") && optionArgument.count == 2 {
            // option argument is present
            let (option, value) = getOption(String(optionArgument.suffix(1)))
            switch option {
            case .repeat:
                arguments.removeFirst() // remove option argument
                if arguments.isEmpty { // there should be at least 1 argument after -r
                    display(error: .tooFewArguments)
                    printUsage()
                } else if arguments.count > 2 { // there should be no more than 2 arguments after -r
                    display(error: .tooManyArguments)
                    printUsage()
                } else {
                    rollRepeat(arguments: arguments)
                }
            case .help:
                printUsage()
            case .unknown, .quit:
                display(error: .invalidOption, option: value)
                printUsage()
            }
        } else {
            // no option present - go straight to parse argument for the roll
            if arguments.count > 1 {
                display(error: .tooManyArguments)
                printUsage()
            } else {
                if let diceCount = Int(optionArgument){
                    if diceCount >= 1 && diceCount <= 6 {
                        rollAndPrint(diceCount: diceCount)
                    } else {
                        // user didn't enter a number between 1 and 6.
                        display(error: .invalidNumber)
                        printUsage()
                    }
                } else {
                    // user didn't enter a number
                    display(error: .invalidOption)
                    printUsage()
                }
            }
        }
        
        func rollRepeat(arguments: [String]) {
            assert((1...2).contains(arguments.count), "rollRepeat called for invalid # of arguments")
            
            if arguments.count == 1 {
                if let diceCount = Int(arguments.first!), (1...6).contains(diceCount) {
                    rollAndPrint(diceCount: diceCount)
                } else {
                    display(error: .invalidNumber)
                    printUsage()
                }
            } else if arguments.count == 2 {
                if let repetitionCount = Int(arguments.first!), (1...10).contains(repetitionCount), let diceCount = Int(arguments[1]), (1...6).contains(diceCount) {
                    rollAndPrint(diceCount: diceCount, repetitionCount: repetitionCount)
                } else {
                    display(error: .invalidNumber)
                    printUsage()
                }
            }
        }
    }
    
    func interactiveMode() {
        // TODO: implementation
        consoleIO.writeMessage("Interactive Mode")
    }
    
    /// This method converts the option string into a tuple of OptionType and the option string
    /// - Parameter option: We expect r or h.  Anything else will be mapped to unknown
    /// - Returns: The OptionType and the option string
    private func getOption(_ option: String) -> (option: OptionType, value: String) {
        return (OptionType(value: option), option)
    }
    
    /// Prints a brief overview of using this CLI tool to the console
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        consoleIO.writeMessage("usage:")
        consoleIO.writeMessage("\(executableName) <# of dices, up to 6>")
        consoleIO.writeMessage("or")
        consoleIO.writeMessage("\(executableName) -r <optional: # of repetitions, default to 2> <# of dices, up to 6>")
        consoleIO.writeMessage("or")
        consoleIO.writeMessage("\(executableName) -h to show usage information")
        consoleIO.writeMessage("Type \(executableName) without an option to enter interactive mode.")
    }
    
    func rollAndPrint(diceCount: Int, repetitionCount: Int = 1) {
        for i in 1...repetitionCount {
            consoleIO.writeMessage("Roll \(i)")
            var dices = Array(repeating: Dice(), count: diceCount)
            for (index, _) in dices.enumerated() {
                dices[index].roll()
                printPips(dices[index].pipsLanded)
                // print space to separate between dices
                    consoleIO.writeMessage("")
            }
        }
    }
    
    func printPips(_ pips: Int) {
        assert((1...6).contains(pips), "pips count out of range")
        // TODO: design logic for printing pips in grid
        
        let backgroundColor: Color = .cyan
        switch pips {
        case 1:
            consoleIO.writeMessage("     ", to: .colored(backgroundColor))
            consoleIO.writeMessage("  *  ", to: .colored(backgroundColor))
            consoleIO.writeMessage("     ", to: .colored(backgroundColor))
        case 2:
            consoleIO.writeMessage("    *", to: .colored(backgroundColor))
            consoleIO.writeMessage("     ", to: .colored(backgroundColor))
            consoleIO.writeMessage("*    ", to: .colored(backgroundColor))
        case 3:
            consoleIO.writeMessage("    *", to: .colored(backgroundColor))
            consoleIO.writeMessage("  *  ", to: .colored(backgroundColor))
            consoleIO.writeMessage("*    ", to: .colored(backgroundColor))
        case 4:
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
            consoleIO.writeMessage("     ", to: .colored(backgroundColor))
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
        case 5:
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
            consoleIO.writeMessage("  *  ", to: .colored(backgroundColor))
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
        case 6:
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
            consoleIO.writeMessage("*   *", to: .colored(backgroundColor))
        default:
            return
        }
    }
    
    private func display(error: ErrorType, option: String? = nil) {
        switch error {
        case .invalidNumber:
            consoleIO.writeMessage("invalid number", to: .error)
        case .invalidOption:
            consoleIO.writeMessage("invalid \(option ?? "")option", to: .error)
        case .tooFewArguments:
            consoleIO.writeMessage("too few arguments", to: .error)
        case .tooManyArguments:
            consoleIO.writeMessage("too many arguments", to: .error)
        }
    }
}
