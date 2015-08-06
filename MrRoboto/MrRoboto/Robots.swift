//
//  Robots.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Things having to do with robots

import UIKit

extension CellGridViewController {
    
    // Put robots in their initial positions
    func initializeRobots() {
        robotOne.position = CellGridViewController.RobotOneInitialPosition
        robotTwo.position = CellGridViewController.RobotTwoInitialPosition
        
        robotOne.state = .Normal
        robotTwo.state = .Normal
    }
    
    // Called each time a robot's timer fires.  This is where the robot's move computation begins.
    func updateRobot(robot: Robot) {
        // Fire off an asynchronous request to get the current grid.
        cellGridManager.getGrid() {
            (currentGrid: CellGrid?) in
            
            if currentGrid != nil {
                if let (position, expectedState) = robot.computeMove(currentGrid!) {
                    // Robot found a valid move.  Queue up a task to make the move.
                    dispatch_async(self.actionQueueForRobot(robot)) {
                        self.moveRobot(robot, originalGrid: currentGrid!, newPosition: position, expectedState: expectedState)
                    }
                    return
                }
            }
            
            // No valid moves
            robot.state = .Stuck
        }
    }
    
    // Update the state of the grid based on the move this robot wants to do.  If the move is no longer valid,
    // the grid remains unchanged.
    private func moveRobot(robot: Robot, originalGrid: CellGrid, newPosition: Position, expectedState: CellState) {
        var newGrid = CellGrid(originalGrid)

        // Leave or erase the trail
        if let validCurrentPosition = robot.position {
            newGrid[validCurrentPosition] = expectedState == .Empty ? robot.trailCellState : .Empty
        }

        // Move to the new position
        newGrid[newPosition] = robot.occupyCellState
        
        cellGridManager.setGridConditionally(newGrid,
            condition: {
                (currentGrid: CellGrid?) in
                
                // Current state of the grid.  This might be different than what it was when we computed the move.
                if currentGrid == nil {
                    return false
                }
                
                // Just check to see if the grid changed between the time we computed the move and now.  If it has, don't
                // make the move.
                // (could potentially do optimization here -- like only comparing the states of specific cells)
                return currentGrid! == originalGrid
            },
            completion: {
                (resultantGrid: CellGrid?, modified: Bool) in
                
                if modified {
                    // This shouldn't happen (programmer error)
                    assert(resultantGrid != nil, "grid is nil, but modified is true")

                    // Our move was successful!
                    robot.position = newPosition
                    
                    // If our move was successful and we were going for the prize,
                    // we've scored!
                    if expectedState == .Prize {
                        robot.state = .Scored
                        robot.score++
                    }

                    // Update the UI
                    dispatch_async(dispatch_get_main_queue()) {
                        self.completeRobot(robot, grid: resultantGrid!)
                    }
                }
        })
    }
    
    // A robot completed a move.  Update the UI.
    func completeRobot(robot: Robot, grid: CellGrid) {
        cellGridView.grid = grid
        
        if robot.state == .Scored {
            if robot == robotOne {
                robotOneScoreView.score = robotOne.score
            }
            else if robot == robotTwo {
                robotTwoScoreView.score = robotTwo.score
            }
            else {
                fatalError("Invalid robot")
            }
            reset()
            run()
        }
        else if allRobotsStuck {
            reset()
            run()
        }
    }
    
    private var allRobotsStuck: Bool {
        return robotOne.state == .Stuck && robotTwo.state == .Stuck
    }
    
    private func actionQueueForRobot(robot: Robot) -> dispatch_queue_t {
        if robot == robotOne {
            return robotOneActionQueue
        }
        else if robot == robotTwo {
            return robotTwoActionQueue
        }
        
        fatalError("Invalid robot")
    }
}

class Robot: NSObject {
    enum State: String {
        // Going
        case Normal = "Normal"
        
        // Robot got the prize!
        case Scored = "Scored"
        
        // No possible moves
        case Stuck = "Stuck"
    }
    
    var state: State = .Normal
    var position: Position?
    var score: Int = 0
    
    // States in the CellGrid which correspond to this robot (i.e. .RobotOne, .RobotTwo, etc.)
    var occupyCellState: CellState
    var trailCellState: CellState
    
    required init(occupyCellState: CellState, trailCellState: CellState) {
        self.occupyCellState = occupyCellState
        self.trailCellState = trailCellState
    }
    
    private var adjacentPositions: [Position]? {
        if position == nil {
            return nil
        }
        
        let allAdjacentPositions = [position!.left, position!.right, position!.above, position!.below]
        return allAdjacentPositions.filter { !$0.outOfBounds }
    }
    
    // Figure out a new place to be
    //
    // Currently, this isn't a very intelligent computation -- it just picks a move at random.
    // But, since this happens in its own queue and doesn't tie up anything else, the robot could potentially take as long
    // is it wanted to think about its move! Of course, the move might not be valid by the time the robot makes up its mind; but, that
    // doesn't affect anything else in the simulation.
    func computeMove(grid: CellGrid) -> (move: Position, expectedState: CellState)? {
        if let currentAdjacentPositions = adjacentPositions {

            // Look for the prize
            let winningPositions = currentAdjacentPositions.filter { grid[$0] == .Prize }
            if let firstWinningPosition = winningPositions.first {
                return (firstWinningPosition, .Prize)
            }
            
            // No prizes!  Check for empty spots.
            let emptyPositions = currentAdjacentPositions.filter { grid[$0] == .Empty }
            
            if !emptyPositions.isEmpty {
                // Pick a random empty spot
                return (emptyPositions[random() % emptyPositions.count], .Empty)
            }
            
            // No empty spots.  Check if we can backtrack.
            let backtrackPositions = currentAdjacentPositions.filter { grid[$0] == self.trailCellState }
            
            if !backtrackPositions.isEmpty {
                // Pick a random backtrack spot
                return (backtrackPositions[random() % backtrackPositions.count], trailCellState)
            }
            
            // No possible moves!
            state = .Stuck
            return nil
        }
        
        // Our position hasn't been set
        return nil
    }
}

