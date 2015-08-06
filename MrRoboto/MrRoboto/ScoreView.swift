//
//  ScoreView.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// A robot's scoreboard

import UIKit

class ScoreView: UIView, HasAssociatedNib {
    static var NibName = "ScoreView"
    
    @IBInspectable var color: UIColor = UIColor.grayColor() { didSet { setNeedsLayout() } }
    @IBInspectable var score: Int = 0 { didSet { setNeedsLayout() } }
    
    @IBOutlet weak var colorCircleView: OvalView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return UIView.replaceWithInstanceFromNib(self)
    }
 
    // Update display
    override func layoutSubviews() {
        colorCircleView.color = color
        scoreLabel.text = "\(score)"
    }
}
