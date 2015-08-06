//
//  CellGridViewController.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// General UI handling, initialization and state

import UIKit

class CellGridViewController: UIViewController {
    static var RobotUpdateInterval: UInt64 = NSEC_PER_SEC/2
    static var RobotUpdateLeeway: UInt64 = NSEC_PER_SEC/4
    static var RobotOneInitialPosition = Position(0, CellGrid.Dimensions.y - 1)
    static var RobotTwoInitialPosition = Position(CellGrid.Dimensions.x - 1, 0)

    @IBOutlet weak var cellGridView: CellGridView!
    @IBOutlet weak var robotOneScoreView: ScoreView!
    @IBOutlet weak var robotTwoScoreView: ScoreView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // Synchronizes access to simulation state
    let cellGridManager = CellGridManager()
    
    // The robots
    let robotOne = Robot(occupyCellState: CellState.RobotOne, trailCellState: CellState.RobotTrailOne)
    let robotTwo = Robot(occupyCellState: CellState.RobotTwo, trailCellState: CellState.RobotTrailTwo)
    
    // Robot actions (computing and making moves) are queued here
    let robotOneActionQueue = dispatch_queue_create("Robot One Action Queue", DISPATCH_QUEUE_SERIAL)
    let robotTwoActionQueue = dispatch_queue_create("Robot Two Action Queue", DISPATCH_QUEUE_SERIAL)
    
    var robotOneTimerSource: dispatch_source_t?
    var robotTwoTimerSource: dispatch_source_t?

    // Simulation control variables
    var goButtonState: GoButtonState = .Go {
        didSet {
            goButton.setTitle(goButtonState.rawValue, forState: UIControlState.Normal)
        }
    }
    
    var simulationState: SimulationState = .Stopped {
        didSet {
            switch (simulationState) {
            case .Stopped:
                resetButton.enabled = true
                goButtonState = .Go
                break
            case .Running:
                resetButton.enabled = false
                goButtonState = .Stop
            }
            resetButton.setNeedsDisplay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cellGridView.setTranslatesAutoresizingMaskIntoConstraints(false)

        resetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        resetButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        
        reset()
    }
    
    // All the places a prize can be
    let validPrizePositions: [Position] = {
        var allPositions: [Position] = []
        for row in 0..<CellGrid.Dimensions.y {
            for column in 0..<CellGrid.Dimensions.x {
                allPositions.append(Position(column, row))
            }
        }
        return allPositions.filter {
            !(($0 == CellGridViewController.RobotOneInitialPosition) || ($0 == CellGridViewController.RobotTwoInitialPosition))
        }
    }()

    // Set up a new game grid, but don't reset the score
    func initializeGrid() {
        var grid = CellGrid()

        if robotOne.position != nil {
            grid[robotOne.position!] = .RobotOne
        }
        if robotTwo.position != nil {
            grid[robotTwo.position!] = .RobotTwo
        }
        
        let prizePosition = validPrizePositions[random() % validPrizePositions.count]
        grid[prizePosition] = .Prize

        cellGridView.grid = grid
        cellGridManager.setGrid(grid)
    }
}
