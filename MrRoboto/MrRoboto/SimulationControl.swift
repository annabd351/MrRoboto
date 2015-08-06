//
//  SimulationControl.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Starting, stopping, and resetting the simulation

import UIKit

extension CellGridViewController {
    enum GoButtonState: String {
        case Go = "Go"
        case Stop = "Stop"
    }

    @IBAction func goPressed(sender: AnyObject) {
        switch (goButtonState) {
        case .Go:
            goButtonState = .Stop
            run()
            break
        case .Stop:
            goButtonState = .Go
            stop()
            break
        }
    }
    
    enum SimulationState: String {
        case Running = "Running"
        case Stopped = "Stopped"
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        reset()
    }
    
    func run() {
        if let validRobotOneTimerSource = robotOneTimerSource,
            let validRobotTwoTimerSource = robotTwoTimerSource {
                dispatch_resume(validRobotOneTimerSource)
                dispatch_resume(validRobotTwoTimerSource)
                simulationState = .Running
        }
        else {
            // Programmer error
            fatalError("Timers don't exist")
        }
    }
    
    func stop() {
        if let validRobotOneTimerSource = robotOneTimerSource,
            let validRobotTwoTimerSource = robotTwoTimerSource {
                dispatch_suspend(validRobotOneTimerSource)
                dispatch_suspend(validRobotTwoTimerSource)
                simulationState = .Stopped
        }
        else {
            // Programmer error
            fatalError("Timers don't exist")
        }
    }

    func reset() {
        if simulationState == .Running {
            stop()
        }
        
        if let validRobotOneTimerSource = robotOneTimerSource,
            let validRobotTwoTimerSource = robotTwoTimerSource {

                // Cancelling a source which is currently suspended puts it in a state where it
                // can't later be released. Since we need to (implicitly) release it, resume it
                // and then cancel it.
                dispatch_resume(validRobotOneTimerSource)
                dispatch_resume(validRobotTwoTimerSource)

                dispatch_source_cancel(validRobotOneTimerSource)
                dispatch_source_cancel(validRobotTwoTimerSource)
                simulationState = .Stopped
        }

        createTimerSources()
        initializeRobots()
        initializeGrid()
    }

    func createTimerSources() {
        let newRobotOneTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        let newRobotTwoTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

        robotOneTimerSource = newRobotOneTimerSource
        robotTwoTimerSource = newRobotTwoTimerSource
        
        dispatch_source_set_timer(robotOneTimerSource!, DISPATCH_TIME_NOW, CellGridViewController.RobotUpdateInterval, CellGridViewController.RobotUpdateLeeway)
        dispatch_source_set_timer(robotTwoTimerSource!, DISPATCH_TIME_NOW, CellGridViewController.RobotUpdateInterval, CellGridViewController.RobotUpdateLeeway)

        dispatch_source_set_event_handler(robotOneTimerSource!) {
            dispatch_async(self.robotOneActionQueue) {
                self.updateRobot(self.robotOne)
            }
        }
        
        dispatch_source_set_event_handler(robotTwoTimerSource!) {
            dispatch_async(self.robotTwoActionQueue) {
                self.updateRobot(self.robotTwo)
            }
        }
    }
}
