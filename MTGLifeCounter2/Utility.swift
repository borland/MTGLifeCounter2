//
//  Utility.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

public let GlobalTintColor = UIColor(red: 0.302, green: 0.102, blue: 0.702, alpha: 1)

// swift 2.2 compiler +'ing more than 3 arrays together takes minutes to COMPILE, so we don't + them
func concat<T>(arrays: [[T]]) -> [T] {
    var result = [T]()
    for array in arrays {
        result.appendContentsOf(array)
    }
    return result
}

extension UIView {
    func addConstraints(format:String, views:[String:UIView], metrics:[String:CGFloat]? = nil, options:NSLayoutFormatOptions=NSLayoutFormatOptions(rawValue: 0)) {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(
            format,
            options: options,
            metrics: metrics,
            views: views)
        
        self.addConstraints(constraints)
    }
    
    func addAllConstraints(constraints: [NSLayoutConstraint]...) {
        addConstraints(concat(constraints))
    }
    
    func removeAllConstraints(constraints: [NSLayoutConstraint]...) {
        removeConstraints(concat(constraints))
    }
}

extension SequenceType where Generator.Element == NSLayoutConstraint {
    func affectingView(view: UIView) -> [NSLayoutConstraint] {
        return filter {
            if let first = $0.firstItem as? UIView where first == view {
                return true
            }
            if let second = $0.secondItem as? UIView where second == view {
                return true
            }
            return false
        }
    }
}

//! The UInt is the number rolled on the dice face, the Bool is true if this is the "winning" value
func randomUntiedDiceRolls(numDice:Int, diceFaceCount:UInt) -> [(UInt, Bool)] {
    var values = Array(count:numDice, repeatedValue:UInt(1))

    // find the indexes of values that have the highest value, and replace those values with randoms. Repeat until no ties
    while true {
        let maxVal = values.maxElement()! // we only care if the highest dice rolls are tied (e.g. if there are 3 people and the dice go 7,2,2 that's fine)
        let tiedValueIndexes = findIndexes(values, value: maxVal)
        if tiedValueIndexes.count < 2 {
            break
        }
        
        for ix in tiedValueIndexes {
            values[ix] = UInt(arc4random_uniform(UInt32(diceFaceCount)) + 1)
        }
    }
    let maxVal = values.maxElement()!
    return values.map{ x in (x, x == maxVal) }
}

func delay(seconds: NSTimeInterval, block: dispatch_block_t) -> () -> () {
    var canceled = false // volatile? lock?
    let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(dt, dispatch_get_main_queue()) {
        if !canceled {
            block()
        }
    }
    
    return {
        canceled = true
    }
}

func findIndexes<T : Equatable>(domain:[T], value:T) -> [Int] {
    return domain
        .enumerate()
        .filter{ (ix, obj) in obj == value }
        .map{ (ix, obj) in ix }
}