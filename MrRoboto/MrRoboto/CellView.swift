//
//  CellView.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Single cell in the game grid

import UIKit

@IBDesignable
class CellView: UIView {

    // Empty space around circle
    @IBInspectable var inset: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    // Colors
    @IBInspectable var robotOneColor: UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    @IBInspectable var robotTrailOneColor: UIColor = UIColor(red: 0.75, green: 0.50, blue: 0.50, alpha: 1)
    @IBInspectable var robotTwoColor: UIColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
    @IBInspectable var robotTrailTwoColor: UIColor = UIColor(red: 0.50, green: 0.50, blue: 0.75, alpha: 1)
    @IBInspectable var emptyColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var prizeColor: UIColor = UIColor(red: 0.25, green: 0.75, blue: 0.25, alpha: 1)

    // What's currently displayed
    var state: CellGrid.CellState? { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        if let currentState = state {
            switch (currentState) {
            case .Prize:
                drawCircle(rect, color: prizeColor)
                break
            case .RobotOne:
                drawCircle(rect, color: robotOneColor)
                break
            case .RobotTwo:
                drawCircle(rect, color: robotTwoColor)
                break
            case .RobotTrailOne:
                drawCircle(rect, color: robotTrailOneColor)
                break
            case .RobotTrailTwo:
                drawCircle(rect, color: robotTrailTwoColor)
                break
            case .Empty:
                drawCircle(rect, color: emptyColor)
                break
            }
        }
    }
    
    private func drawCircle(rect: CGRect, color: UIColor) {
        let circlePath = UIBezierPath(ovalInRect: UIEdgeInsetsInsetRect(rect, inset))
        
        color.setFill()
        color.setStroke()
        
        circlePath.stroke()
        circlePath.fill()
    }
}
