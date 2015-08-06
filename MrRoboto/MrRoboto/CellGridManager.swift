//
//  CellGridManager.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Manage thread-safe access to a CellGrid

import Foundation

class CellGridManager {
    
    // Current grid
    private var grid: CellGrid?

    // Synchronization queue
    private let accessQueue = dispatch_queue_create("CellGrid Access Queue", DISPATCH_QUEUE_CONCURRENT)
    
    // Asynchronously retreive the current grid
    func getGrid(completion: (CellGrid?) -> ()) {
        dispatch_async(accessQueue) {
            completion(self.grid)
        }
    }
    
    // Synchronously set the grid
    func setGrid(grid: CellGrid) {
        dispatch_barrier_sync(accessQueue) {
            self.grid = grid
        }
    }
    
    // Asynchronously set the grid if the condition is true.  Return the resultant grid, and a flag indicating that it was modified.
    // This allows robots to compute moves without waiting for write access to the grid -- if the grid state is different than
    // what it was when the robot read the grid, it simply doesn't make the move.
    func setGridConditionally(newGrid: CellGrid, condition: (CellGrid?) -> Bool, completion: (CellGrid?, Bool) -> ()) {
        dispatch_barrier_async(accessQueue) {
            if condition(self.grid) {
                self.grid = newGrid
                completion(self.grid, true)
            }
            completion(self.grid, false)
        }
    }
}
