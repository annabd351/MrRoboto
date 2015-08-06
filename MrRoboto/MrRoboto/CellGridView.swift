//
//  CellGridView.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Display the game grid

import UIKit

class CellGridView: UIView, HasAssociatedNib {
    static var NibName = "CellGridView"
    
    // CellGrid this view displays
    var grid: CellGrid? { didSet { setNeedsLayout() } }
    
    @IBOutlet private var rowViews: [CellRowView]!
    
    // Load instance from nib
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        return UIView.replaceWithInstanceFromNib(self)
    }

    // Update display to the current grid
    override func layoutSubviews() {
        if let validGrid = grid {
            for rowIndex in 0..<CellGrid.Dimensions.y {
                for columnIndex in 0..<CellGrid.Dimensions.x {
                    let position = Position(columnIndex, rowIndex)
                    cellView(position).state = validGrid[position]
                }
            }
        }
    }

    private func cellView(position: CellGrid.Position) -> CellView {
        return rowViews[position.y].cells[position.x]
    }
}


