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
func concat<T>(_ arrays: [[T]]) -> [T] {
    var result = [T]()
    for array in arrays {
        result.append(contentsOf: array)
    }
    return result
}

extension UIView {
    func addConstraints(_ format:String, views:[String:UIView], metrics:[String:CGFloat]? = nil, options:NSLayoutConstraint.FormatOptions=NSLayoutConstraint.FormatOptions(rawValue: 0)) {
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: format,
            options: options,
            metrics: metrics,
            views: views)
        
        self.addConstraints(constraints)
    }
    
    func addAllConstraints(_ constraints: [NSLayoutConstraint]...) {
        addConstraints(concat(constraints))
    }
    
    func removeAllConstraints(_ constraints: [NSLayoutConstraint]...) {
        removeConstraints(concat(constraints))
    }
}

extension Sequence where Iterator.Element == NSLayoutConstraint {
    func affectingView(_ view: UIView) -> [NSLayoutConstraint] {
        return filter {
            if let first = $0.firstItem as? UIView, first == view {
                return true
            }
            if let second = $0.secondItem as? UIView, second == view {
                return true
            }
            return false
        }
    }
}

//! The UInt is the number rolled on the dice face, the Bool is true if this is the "winning" value
func randomUntiedDiceRolls(_ numDice:Int, diceFaceCount:UInt) -> [(UInt, Bool)] {
    var values = Array(repeating: UInt(1), count: numDice)

    // find the indexes of values that have the highest value, and replace those values with randoms. Repeat until no ties
    while true {
        let maxVal = values.max()! // we only care if the highest dice rolls are tied (e.g. if there are 3 people and the dice go 7,2,2 that's fine)
        let tiedValueIndexes = findIndexes(values, value: maxVal)
        if tiedValueIndexes.count < 2 {
            break
        }
        
        for ix in tiedValueIndexes {
            values[ix] = UInt(arc4random_uniform(UInt32(diceFaceCount)) + 1)
        }
    }
    let maxVal = values.max()!
    return values.map{ x in (x, x == maxVal) }
}

func delay(_ seconds: TimeInterval, block: @escaping ()->()) -> () -> () {
    var canceled = false // volatile? lock?
    let dt = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dt) {
        if !canceled {
            block()
        }
    }
    
    return {
        canceled = true
    }
}

func findIndexes<T : Equatable>(_ domain:[T], value:T) -> [Int] {
    return domain
        .enumerated()
        .filter{ (ix, obj) in obj == value }
        .map{ (ix, obj) in ix }
}

enum ContainerOrientation {
    case portrait, landscape
}

extension UIView {
    /** returns the "orientation" of the VIEW ITSELF, not neccessarily the screen */
//    var orientation : ScreenOrientation {
//        return bounds.size.orientation
//    }
}

extension CGSize {
    var orientation : ContainerOrientation {
        return (width > height) ? .landscape : .portrait
    }
}
