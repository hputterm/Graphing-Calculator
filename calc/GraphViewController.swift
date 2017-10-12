//
//  ViewController.swift
//  graphing
//
//  Created by Harry Putterman on 7/13/17.
//  Copyright © 2017 Harry Putterman. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView!{
        didSet{
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: #selector(graphView.tap(recognizer:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.pan(recognizer:))))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom(recognizer:))))
        }
    }
    var function: ((Double)->(Double))?
    override func viewDidLoad() {
        super.viewDidLoad()
        let newFunction = function
        graphView.function = newFunction
    }
}

