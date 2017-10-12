//
//  GraphView.swift
//  graphing
//
//  Created by Harry Putterman on 7/13/17.
//  Copyright © 2017 Harry Putterman. All rights reserved.
//

import UIKit
@IBDesignable
class GraphView: UIView {
    var ppu: CGFloat = 100 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    private var drawer = AxesDrawer(color: UIColor.black, contentScaleFactor: UIScreen.main.scale) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var originOfCoordinates: CGPoint? = nil { didSet {setNeedsDisplay() } }
    var function: ((Double) -> Double)? {
        didSet{
            setNeedsDisplay()
        }
    }
    /**
    Does the actual drawing of the function.
    */
    override func draw(_ rect: CGRect) {
        originOfCoordinates = originOfCoordinates ?? CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        let rectToDrawIn: CGRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.maxX, height: bounds.maxY)
        drawer.drawAxes(in: rectToDrawIn, origin: originOfCoordinates!, pointsPerUnit: ppu)
        color.set()
        drawFunctionPath().stroke()
    }
    /**
    Generates the path for the function using UIBezierPath.
    */
    func drawFunctionPath()->UIBezierPath{
        let path = UIBezierPath()
        if function == nil{
            return path
        }
        var restart: Bool = true
        for x in 0...Int(bounds.size.width){
            let xValue: CGFloat = CGFloat(x) - originOfCoordinates!.x
            let yValue: CGFloat = ppu * CGFloat(function!(Double(xValue)/Double(ppu)))
            if !yValue.isZero && !yValue.isNormal {
                restart = true
                continue
            }
            if restart {
                path.move(to: CGPoint(x: CGFloat(x), y: convertYtoCG(yValue)))
                restart = false
            } else {
                path.addLine(to: CGPoint(x: CGFloat(x), y: convertYtoCG(yValue)))
            }
        }
        return path
    }
    //converts coordinate conventions.
    func convertXtoCG(_ x: CGFloat)->CGFloat{
        return x + originOfCoordinates!.x
    }
    //converts coordinate conventions.
    func convertYtoCG(_ y: CGFloat)->CGFloat{
        return originOfCoordinates!.y - y
    }
    //recognizes taps.
    func tap(recognizer: UITapGestureRecognizer){
        if recognizer.state == .ended {
            originOfCoordinates = recognizer.location(in: self)
        }
    }
    //recognizes pans.
    func pan(recognizer: UIPanGestureRecognizer){
        if recognizer.state == .changed || recognizer.state == .ended {
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(CGPoint(x: 0,y: 0), in: self)
            originOfCoordinates!.x += translation.x
            originOfCoordinates!.y += translation.y
        }
    }
    //recognizes zooms.
    func zoom(recognizer: UIPinchGestureRecognizer){
        if recognizer.state == .ended || recognizer.state == .changed {
            ppu *= recognizer.scale
            recognizer.scale = 1
        }
    }
}
