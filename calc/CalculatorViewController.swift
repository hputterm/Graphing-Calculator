//
//  ViewController.swift
//  calc
//
//  Created by Harry Putterman on 6/25/17.
//  Copyright © 2017 Harry Putterman. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    var userIsTyping = false
    @IBOutlet weak var pathDisplay: UILabel!
    var typingDecimal = false
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            let textInDisplay = display.text!
            if !(textInDisplay.contains(".") && digit=="."){
                display.text = textInDisplay + digit
            }
        } else {
            display.text = digit
            userIsTyping = true
            pathDisplay.text = brain.descriptionString!
        }
    }
    var displayValue: Double
    {
        get
        {
            return Double(display.text!)!
        }
        set
        {
            display.text = String(newValue)
        }
    }
    private var brain: CalculatorBrain = CalculatorBrain()
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = brain.result ?? 0
    }
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping
        {
            brain.setOperand(displayValue)
            userIsTyping=false
        }
        userIsTyping = false
        if let symbol = sender.currentTitle
        {
            brain.performOperation(symbol)
        }
        if let result = brain.result
        {
            displayValue = result
        }
        pathDisplay.text = brain.descriptionString!
    }
    @IBAction func touchVariable(_ sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
    }
    @IBAction func evaluateVariable(_ sender: UIButton) {
        brain.setInternalDictionary(using: ["M":Double(displayValue)])
        displayValue = brain.result ?? 0
        userIsTyping = false
    }
    @IBAction func Undo(_ sender: UIButton) {
        if userIsTyping
        {
            var stringDisplay = display.text!
            stringDisplay.remove(at: stringDisplay.index(before: stringDisplay.endIndex))
            display.text = stringDisplay
        }
        else
        {
            brain.undo()
            displayValue = brain.result!
        }
        pathDisplay.text = brain.descriptionString!
    }
    func funcForGraphView(_ value: Double)->Double {
        return brain.ezEvaluate(using: ["M":value]).result!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let graphViewController = destinationViewController as? GraphViewController {
            if let identifier = segue.identifier{
                switch identifier {
                case "DisplayGraph":
                    if brain.ezEvaluate(using: ["M":0]).isPending == true || brain.ezEvaluate(using: ["M":0]).result == nil{
                        break
                    }
                    graphViewController.function = funcForGraphView(_:)
                    let nameString = brain.descriptionString!
                    print(nameString)
                    graphViewController.navigationItem.title = String(nameString)
                default:
                    break
                }
            }
        }
    }
}

