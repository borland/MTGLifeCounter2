//
//  NumberWheelView.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 14/05/15.
//  Copyright (c) 2015 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class NumberWheelView : UIView {
    
    private var labels = [(UILabel, NSLayoutConstraint)]()
    private let numCells = 50
    
    private let lineHeight:CGFloat
    private let lineGap:CGFloat = 5
    private let totalLineHeight:CGFloat
    
    required init(coder aDecoder: NSCoder) {
        lineHeight = 20
        totalLineHeight = lineHeight + lineGap
        super.init(coder: aDecoder)
        configureView()
    }
    
    required init(fontSize:CGFloat) {
        lineHeight = fontSize
        totalLineHeight = lineHeight + lineGap
        super.init(frame:CGRectZero)
        configureView()
    }
    
    func configureView() {
        clipsToBounds = true
        
        setTranslatesAutoresizingMaskIntoConstraints(false) // it's up to the parent to set layout constraints
        
        for var x = -1; x < numCells+2; x++ {
            let lbl = UILabel()
            lbl.setTranslatesAutoresizingMaskIntoConstraints(false)
            lbl.font = UIFont(name: "Futura", size: CGFloat(lineHeight))
            lbl.text = "\(arc4random_uniform(20)+1)"
            
            if x == numCells {
                lbl.text = "IT'S ME"
            }
            
            addSubview(lbl)
            addConstraint(NSLayoutConstraint(item: lbl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            
            let vOffset = CGFloat(x) * totalLineHeight
            let vConstraint = NSLayoutConstraint(item: lbl, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: CGFloat(vOffset))
            addConstraint(vConstraint)
            
            labels.append((lbl, vConstraint))
        }
    }
    
    func spin(duration:NSTimeInterval = 2.5) {
        let thresholdPositive = CGFloat(totalLineHeight*2)
        let thresholdNegative = -thresholdPositive
        let animOvershoot = totalLineHeight / 4
        
        let heightOffset = totalLineHeight * CGFloat(numCells) + CGFloat(animOvershoot)
        for (lbl, constraint) in labels {
            constraint.constant -= heightOffset
        }
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.layoutIfNeeded()
            }, completion:{ _ in
                var validIndexes = [Int]()
                
                for (idx, (lbl, constraint)) in enumerate(self.labels) {
                    // remove all but the ones on screen
                    let c = constraint.constant
                    if !(c > thresholdNegative && c < thresholdPositive) {
                        lbl.removeFromSuperview()
                    } else {
                        validIndexes.append(idx)
                    }
                }
                
                for idx in validIndexes {
                    let (lbl, constraint) = self.labels[idx]
                    constraint.constant += CGFloat(animOvershoot) // fix the overshoot
                    
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.layoutIfNeeded()
                        }, completion: { _ in
                            self.labels.removeAll(keepCapacity: false)
                            // now the only references to the labels should be the view itself
                    })
                }
        })
    }
}