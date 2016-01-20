//
//  CellGrid.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Data structure which stores the state of the game grid

import Foundation

struct CellGrid {
    
    // For simplicity, CellGrids have fixed dimensions
    static var Dimensions = (x: 7, y: 7)

    // State of each cell in the grid
    enum CellState: String {
        // Nothing here
        case Empty = "Empty"
        
        // Prize is in this cell
        case Prize = "Prize"
        
        // Robot one/two is currently here
        case RobotOne = "RobotOne"
        case RobotTwo = "RobotTwo"
        
        // Robot one/two was here, and has left a trail
        case RobotTrailOne = "RobotTrailOne"
        case RobotTrailTwo = "RobotTrailTwo"
    }
    
    // Array of states in this grid
    var states = [[CellState]](count: CellGrid.Dimensions.y, repeatedValue: [CellState](count: CellGrid.Dimensions.x, repeatedValue: .Empty))
    
    // Accessors
    // Values outside the grid bounds wrap around
    subscript(column: Int, row: Int) -> CellState {
        get {
            return states[CellGrid.wrappedRow(row)][CellGrid.wrappedColumn(column)]
        }
        set {
            states[CellGrid.wrappedRow(row)][CellGrid.wrappedColumn(column)] = newValue
        }
    }

    struct Position {
        let x, y: Int
    }
    
    subscript(position: Position) -> CellState {
        get {
            return states[CellGrid.wrappedRow(position.y)][CellGrid.wrappedColumn(position.x)]
        }
        set {
            states[CellGrid.wrappedRow(position.y)][CellGrid.wrappedColumn(position.x)] = newValue
        }
    }
    
    static func wrappedRow(originalRow: Int) -> Int {
        if originalRow < 0 {
            return CellGrid.Dimensions.y + originalRow
        }
        
        let newRow = originalRow % CellGrid.Dimensions.y
        if newRow < 0 {
            return originalRow + newRow
        }
        else {
            return newRow
        }
    }

    static func wrappedColumn(originalColumn: Int) -> Int {
        if originalColumn < 0 {
            return CellGrid.Dimensions.x + originalColumn
        }

        let newColumn = originalColumn % CellGrid.Dimensions.x
        if newColumn < 0 {
            return originalColumn + newColumn
        }
        else {
            return newColumn
        }
    }

    init() { }
    
    // Copy constructor
    init(_ original: CellGrid) {
        self.states = original.states
    }
}

func ==(lhs: CellGrid, rhs: CellGrid) -> Bool {
    for rowIndex in 0..<CellGrid.Dimensions.y {
        for columnIndex in 0..<CellGrid.Dimensions.x {
            if lhs.states[columnIndex][rowIndex] != rhs.states[columnIndex][rowIndex] {
                return false
            }
        }
    }
    return true
}

func ==(lhs: CellGrid.Position, rhs: CellGrid.Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension CellGrid.Position {
    // Syntactic sugar for initialization
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    // Relative positions
    var left: Position { return Position(self.x - 1, self.y) }
    var right: Position { return Position(self.x + 1, self.y) }
    var above: Position { return Position(self.x, self.y - 1) }
    var below: Position { return Position(self.x, self.y + 1) }
    
    var outOfBounds: Bool {
        return self.x < 0 || self.x > (CellGrid.Dimensions.x - 1) || self.y < 0 || self.y > (CellGrid.Dimensions.y - 1)
    }
}

typealias Position = CellGrid.Position
typealias CellState = CellGrid.CellState

extension CellGrid.Position: CustomDebugStringConvertible {
    var debugDescription: String { return "x: \(self.x) y: \(self.y)" }
}
