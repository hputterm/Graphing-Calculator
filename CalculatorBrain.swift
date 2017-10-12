//
//  CalculatorBrain.swift
//  calc
//
//  Created by Harry Putterman on 6/26/17.
//  Copyright © 2017 Harry Putterman. All rights reserved.
//
//
//  newCalculatorBrain.swift
//  calc
//
//  Created by Harry Putterman on 7/4/17.
//  Copyright © 2017 Harry Putterman. All rights reserved.
//

import Foundation
struct CalculatorBrain {
    private var sequenceOfEvents: Array<typesOfThings> = []
    private var variableDictionary: Dictionary<String, Double>? = nil
    private enum Operation
    {
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double, Double)->Double)
        case equals
        case clear
    }
    private enum typesOfThings
    {
        case operations(String)
        case variables(String)
        case operands(Double)
    }
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "log": Operation.unaryOperation(log10),
        "ln": Operation.unaryOperation(log),
        "±": Operation.unaryOperation({-$0}),
        "x": Operation.binaryOperation({$0*$1}),
        "=": Operation.equals,
        "+": Operation.binaryOperation({$0+$1}),
        "-": Operation.binaryOperation({$0-$1}),
        "÷": Operation.binaryOperation({$0/$1}),
        "^": Operation.binaryOperation({pow($0,$1)}),
        "c": Operation.clear
    ]
    /**
    Adds an operation to the sequence of operations.
    */
    mutating func performOperation(_ symbol: String)
    {
        if operations[symbol] != nil
        {
            sequenceOfEvents.append(typesOfThings.operations(symbol))
        }
    }
    private struct pendingBinaryOperation
    {
        let function: (Double, Double)->Double
        let op1: Double
        func perform(with op2: Double)->Double
        {
            return function(op1, op2)
        }
    }
    //sets operand if it is a double.
    mutating func setOperand(_ operand: Double)
    {
        sequenceOfEvents.append(typesOfThings.operands(operand))
    }
    //sets operand if it is a string
    mutating func setOperand(_ operand: String)
    {
        sequenceOfEvents.append(typesOfThings.variables(operand))
    }
    //generates values for the dictionary.
    mutating func setInternalDictionary(using variables: Dictionary<String, Double>)
    {
        variableDictionary=variables
    }
    //resets everything.
    mutating func clear()
    {
        variableDictionary = nil
        sequenceOfEvents = []
    }
    //undoes the last operation or input.
    mutating func undo()
    {
        sequenceOfEvents.removeLast()
    }
    /**
     Generates only the numerical output.
    */
    func ezEvaluate(using variables: Dictionary<String, Double>? = nil)->(result: Double?, isPending: Bool)
    {
        var accumulator: Double?
        var resultIsPending = false
        var setAccumulatorNil = true
        var pbo: pendingBinaryOperation?
        func performPendingBinaryOperation(){
            if pbo != nil && accumulator != nil{
                accumulator = pbo!.perform(with: accumulator!)
            }
        }
        func actuallyPerformOperation(_ symbol: String)
        {
            if let operation = operations[symbol]
            {
                switch operation
                {
                case .constant(let value):
                    accumulator = value
                case .unaryOperation(let function):
                    if accumulator != nil
                    {
                        accumulator = function(accumulator!)
                    }
                case .binaryOperation(let function):
                    setAccumulatorNil = true
                    if resultIsPending {
                        performPendingBinaryOperation()
                        setAccumulatorNil = false
                    }
                    if accumulator != nil{
                        pbo = pendingBinaryOperation(function: function, op1: accumulator!)
                        resultIsPending = true
                        if setAccumulatorNil {
                            accumulator = nil
                        }
                    }
                case .equals:
                    performPendingBinaryOperation()
                    resultIsPending = false
                case .clear:
                    accumulator = nil
                    resultIsPending = false
                }
            }
        }
        for i in sequenceOfEvents
        {
            switch i
            {
            case .operands(let operand):
                accumulator = operand
            case .variables(let operand):
                if let z = variables?[operand]
                {
                    accumulator = z
                }
                else
                {
                    accumulator = 0
                }
            case .operations(let function):
                actuallyPerformOperation(function)
            }
        }
        return (accumulator, resultIsPending)

    }
    /**
    Generates the numerical output and string representing the state.
    */
    func evaluate(using variables: Dictionary<String, Double>? = nil)->(result: Double?, isPending: Bool, description: String)
    {
        var accumulator: Double?
        var justUnary = false
        var normalBinary = false
        var stringOfAccumulator: String?
        var resultIsPending = false
        var description = ""
        var firstClick = true
        var setAccumulatorNil = true
        var pbo: pendingBinaryOperation?
        func lastIndexOf(_ target: String, within input: String)->Int?{
            if let range = input.range(of: target, options: .backwards) {
                return input.distance(from: input.startIndex, to: range.lowerBound)
            } else {
                return nil
            }
        }
        func replaceLastIndex(of target: String, with replacement: String, within input: String)-> String {
            let lastIndex = input.index(input.startIndex, offsetBy: lastIndexOf(target, within: input)!)
            let finalIndex  = description.index(lastIndex, offsetBy: target.characters.count)
            let range: Range<String.Index> = lastIndex..<finalIndex
            return input.replacingOccurrences(of: target, with: replacement, range: range)
        }
        func performPendingBinaryOperation(){
            if pbo != nil && accumulator != nil{
                accumulator = pbo!.perform(with: accumulator!)
            }
        }
        func actuallyPerformOperation(_ symbol: String)
        {
            if let operation = operations[symbol]
            {
                switch operation
                {
                case .constant(let value):
                    accumulator = value
                    stringOfAccumulator = symbol
                    normalBinary = true
                    justUnary = false
                    if !resultIsPending {
                        description = ""
                        firstClick = true
                    }
                    justUnary = false
                case .unaryOperation(let function):
                    if accumulator != nil
                    {
                        if firstClick {
                            description = symbol + "(" + stringOfAccumulator! + ")"
                            firstClick = false
                        }
                        else if justUnary {
                            description = replaceLastIndex(of: stringOfAccumulator!, with: String(symbol + "(" + stringOfAccumulator! + ")"), within: description)
                        }
                        else if !resultIsPending {
                            description = symbol + "(" + description + ")"
                        }
                        else {
                            description.append(symbol + "(" + stringOfAccumulator! + ")")
                        }
                        accumulator = function(accumulator!)
                        stringOfAccumulator = String(symbol + "(" + stringOfAccumulator! + ")")
                    }
                    normalBinary = false
                    justUnary = true
                case .binaryOperation(let function):
                    setAccumulatorNil = true
                    let oldAccumulator = stringOfAccumulator
                    if resultIsPending {
                        performPendingBinaryOperation()
                        setAccumulatorNil = false
                    }
                    if accumulator != nil{
                        pbo = pendingBinaryOperation(function: function, op1: accumulator!)
                        if firstClick {
                            description.append(oldAccumulator! + symbol)
                            firstClick = false
                        }
                        else if !normalBinary{
                            description.append(symbol)
                        }
                        else if resultIsPending {
                            description.append(oldAccumulator! + symbol)
                        }
                        else {
                            description.append(symbol)
                        }
                        resultIsPending = true
                        if setAccumulatorNil {
                            accumulator = nil
                        }
                    }
                    justUnary = false
                case .equals:
                    if (resultIsPending && normalBinary) || firstClick {
                        description.append(stringOfAccumulator!)
                        firstClick = false
                    }
                    performPendingBinaryOperation()
                    resultIsPending = false
                    normalBinary = false
                    justUnary = false
                case .clear:
                    description = ""
                    accumulator = nil
                    stringOfAccumulator = nil
                    resultIsPending = false
                    firstClick = true
                    normalBinary = false
                    justUnary = false
                }
            }
        }
        for i in sequenceOfEvents
        {
            switch i
            {
            case .operands(let operand):
                accumulator = operand
                stringOfAccumulator = String(operand)
                if !resultIsPending {
                    description = ""
                    firstClick = true
                }
                normalBinary = true
                justUnary = false
            case .variables(let operand):
                stringOfAccumulator = operand
                if let z = variables?[operand]
                {
                    accumulator = z
                }
                else
                {
                    accumulator = 0
                }
                if !resultIsPending {
                    description = ""
                    firstClick = true
                }
                normalBinary = true
                justUnary = false
            case .operations(let function):
                actuallyPerformOperation(function)
            }
        }
        return (accumulator, resultIsPending, description)
    }
    var result: Double?
    {
        get
        {
            let toReturn = evaluate(using: variableDictionary).result
            return toReturn
        }
    }
    var descriptionString: String? {
        get {
            return evaluate().description
        }
    }
}
