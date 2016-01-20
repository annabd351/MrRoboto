//
//  Logger.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Synchronous logging

import Foundation

class Logger {
    static var sharedInstance: Logger = {
        return Logger()
    }()
    
    let messageQueue = dispatch_queue_create("Message Queue", DISPATCH_QUEUE_SERIAL)
    
    class func msg(text: String) {
        dispatch_async(Logger.sharedInstance.messageQueue) {
            print(text)
        }
    }
}
