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
    
    private var _labels = [(UILabel, NSLayoutConstraint)]()
    private let _numCells:Int
    private let _lineHeight:CGFloat
    private let _generator:(Int) -> NSAttributedString
    private let _textColor:UIColor
    
    private let _lineGap:CGFloat = 6
    private let _totalLineHeight:CGFloat
    
    required init?(coder aDecoder: NSCoder) {
        _lineHeight = 20
        _numCells = 20
        _generator = { _ in NSAttributedString(string: "-") }
        _totalLineHeight = _lineHeight + _lineGap
        _textColor = UIColor.black
        super.init(coder: aDecoder)
        configureView()
    }
    
    /*! generator will be called consecutively with a series of numbers. 0 is the "target" which the spinner will land on */
    required init(fontSize:CGFloat, textColor: UIColor, numCells:Int, generator:(Int) -> NSAttributedString) {
        _numCells = numCells
        _lineHeight = fontSize
        _generator = generator
        _textColor = textColor
        _totalLineHeight = _lineHeight + _lineGap
        
        super.init(frame:CGRect.zero)
        configureView()
    }
    
    func configureView() {
        translatesAutoresizingMaskIntoConstraints = false // it's up to the parent to set layout constraints
        
        for x in -1 ..< _numCells+2 {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.font = UIFont(name: "Futura", size: CGFloat(_lineHeight))
            lbl.textColor = _textColor
            lbl.attributedText = _generator(_numCells - x)
            
            addSubview(lbl)
            addConstraint(NSLayoutConstraint(item: lbl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            
            let vOffset = CGFloat(x) * _totalLineHeight
            let vConstraint = NSLayoutConstraint(item: lbl, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: CGFloat(vOffset))
            addConstraint(vConstraint)
            
            _labels.append((lbl, vConstraint))
        }
    }
    
    func spinWithDuration(_ duration:TimeInterval) {
        layoutIfNeeded() // before the animation starts
        
        let thresholdPositive = CGFloat(_totalLineHeight*2)
        let thresholdNegative = -thresholdPositive
        let animOvershoot = _totalLineHeight / 4
        
        let heightOffset = _totalLineHeight * CGFloat(_numCells) + CGFloat(animOvershoot)
        for (_, constraint) in _labels {
            constraint.constant -= heightOffset
        }
        
        UIView.animate(withDuration: duration,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations:{ self.layoutIfNeeded() },
            completion:{ _ in
                var validIndexes = [Int]()
                
                for (idx, (lbl, constraint)) in self._labels.enumerated() {
                    // remove all but the ones on screen
                    let c = constraint.constant
                    if !(c > thresholdNegative && c < thresholdPositive) {
                        lbl.removeFromSuperview()
                    } else {
                        validIndexes.append(idx)
                    }
                }
                
                for idx in validIndexes {
                    let (_, constraint) = self._labels[idx]
                    constraint.constant += CGFloat(animOvershoot) // fix the overshoot
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.layoutIfNeeded()
                        }, completion: { _ in
                            self._labels.removeAll(keepingCapacity: false)
                            // now the only references to the labels should be the view itself
                    })
                }
        })
    }
}
