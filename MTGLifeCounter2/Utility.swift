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

func updatePlayerViewController(playerViewController:PlayerViewController, withLifeTotal lifeTotal:NSNumber?, #color:NSNumber?) {
    if let lt = lifeTotal,
        let x = color,
        let col = MtgColor(rawValue: x.integerValue)
    {
        playerViewController.lifeTotal = lt.integerValue
        playerViewController.color = col
    }
}