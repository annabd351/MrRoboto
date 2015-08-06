//
//  CellRowView.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// A row in the grid

import UIKit

class CellRowView: UIView, HasAssociatedNib {
    static var NibName = "CellRowView"

    @IBOutlet var cells: [CellView]!
    
    // Load this view from a nib
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return UIView.replaceWithInstanceFromNib(self)
    }
}

extension UIColor {
    class var randomColor: UIColor {
        func randomZeroOne() -> CGFloat {
            return CGFloat(Double(random())/Double(RAND_MAX))
        }
        return UIColor(red: randomZeroOne(), green: randomZeroOne(), blue: randomZeroOne(), alpha: 1.0)
    }
}