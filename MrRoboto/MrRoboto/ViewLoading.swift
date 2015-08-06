//
//  ViewLoading.swift
//  MrRoboto
//
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Utilities for loading views from nibs

import UIKit

protocol HasAssociatedNib {
    static var NibName: String { get }
}

extension UIView {
    // Given a view, replace it with another instance of that view
    // loaded from a nib.
    
    // This should be used in the awakeAfterUsingCoder method of UIViews.
    class func replaceWithInstanceFromNib<T: UIView where T: HasAssociatedNib>(originalView: T) -> T {
        if originalView.subviews.count == 0 {
            let nib = UINib(nibName: T.NibName, bundle: nil)
            let views = nib.instantiateWithOwner(nil, options: nil)
            let newInstance: AnyObject = views[0]
            newInstance.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            return newInstance as! T
        }
        else {
            return originalView
        }
    }
}