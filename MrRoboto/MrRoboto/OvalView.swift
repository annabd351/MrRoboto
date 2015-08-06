//
//  OvalView.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Draw an oval in a rect

import UIKit

@IBDesignable
class OvalView: UIView {
    @IBInspectable var color: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        color.setFill()
        path.fill()
    }
}
