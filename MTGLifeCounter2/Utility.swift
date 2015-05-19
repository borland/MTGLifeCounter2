//
//  Utility.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addConstraints(format:String, views:[String:UIView], options:NSLayoutFormatOptions=NSLayoutFormatOptions(0)) {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(
            format,
            options: options,
            metrics: nil,
            views: views)
        
        self.addConstraints(constraints)
    }
}

func constraints(ca:[NSLayoutConstraint], #affectingView:UIView) -> [NSLayoutConstraint] {
    return ca.filter {
        if let first = $0.firstItem as? UIView {
            if first == affectingView {
                return true
            }
        }
        if let second = $0.secondItem as? UIView {
            if second == affectingView {
                return true
            }
        }
        return false
    }
}

func resetPlayerViewController(playerViewController:PlayerViewController, withLifeTotal lifeTotal:NSNumber?, #color:NSNumber?) {
    if let lt = lifeTotal,
        let x = color,
        let col = MtgColor(rawValue: x.integerValue)
    {
        playerViewController.resetLifeTotal(lt.integerValue)
        playerViewController.color = col
    }
}

//! The UInt is the number rolled on the dice face, the Bool is true if this is the "winning" value
func randomUntiedDiceRolls(numDice:Int, diceFaceCount:UInt) -> [(UInt, Bool)] {
    var values = Array(count:numDice, repeatedValue:UInt(1))

    // find the indexes of values that have the highest value, and replace those values with randoms. Repeat until no ties
    while true {
        var maxVal = maxElement(values) // we only care if the highest dice rolls are tied (e.g. if there are 3 people and the dice go 7,2,2 that's fine)
        var tiedValueIndexes = findIndexes(values, maxVal)
        if tiedValueIndexes.count < 2 {
            break
        }
        
        for ix in tiedValueIndexes {
            values[ix] = UInt(arc4random_uniform(UInt32(diceFaceCount)) + 1)
        }
    }
    let maxVal = maxElement(values)
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
    var indexes = [Int]()
    for var ix = 0; ix < domain.count; ++ix {
        if domain[ix] == value {
            indexes.append(ix)
        }
    }
    return indexes
}