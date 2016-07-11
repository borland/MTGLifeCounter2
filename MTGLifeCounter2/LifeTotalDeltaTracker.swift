//
//  LifeTotalDeltaTracker.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 12/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class LifeTotalDeltaTracker {
    
    /** How much time the delta tracker stays on screen before "committing" and going away */
    let floatingViewTimeout:NSTimeInterval = 2.5
    
    /** Animation time when the view fades out */
    let floatingViewHideTime:NSTimeInterval = 0.25
    
    private var _baseline = 0 // we show +/- x relative to this.
    private var _history = [(NSDate, Int)]()
    private var _floatingView:FloatingView?
    private let _label = UILabel()
    private var _cancelPreviousDelay:(()->())?
    
    init(fontSize: CGFloat = 44) {
        _label.font = UIFont(name:"Futura", size: 1)
        _label.textColor = UIColor.whiteColor()
        _label.translatesAutoresizingMaskIntoConstraints = false
        
        floatingViewFontSize = fontSize
    }
    
    var floatingViewFontSize: CGFloat {
        didSet {
            _label.font = _label.font.fontWithSize(floatingViewFontSize)
        }
    }
    
    var parent:UIView?
    
    func update(lifeTotal:Int) {
        if let (_, lt) = _history.last {
            if lt == lifeTotal {
                return // no point recording a duplicate
            }
        }
        let tuple = (NSDate(), lifeTotal)
        _history.append(tuple)
        updateUi(lifeTotal)
    }
    
    func reset(lifeTotal:Int) {
        _history.removeAll(keepCapacity: true)
        _baseline = lifeTotal
        updateUi(lifeTotal)
    }
    
    func updateUi(lifeTotal:Int) {
        let symbol = (lifeTotal - _baseline >= 0) ? "+" : "-"
        _label.text = "\(symbol)\(lifeTotal - _baseline)"
        _label.sizeToFit()
        showOrExtendView()
    }
    
    func showOrExtendView() {
        if let p = parent where _floatingView == nil && _history.count > 1 {
            let fv = FloatingView(innerView:self._label, cornerRadius: Float(floatingViewFontSize) / 5)
            
            fv.showInView(p) { floatingView in
                p.addConstraints([
                    NSLayoutConstraint(item: floatingView, attribute: .Left, relatedBy: .Equal, toItem: p, attribute: .Left, multiplier: 1.0, constant: 5.0),
                    NSLayoutConstraint(item: floatingView, attribute: .Top, relatedBy: .Equal, toItem: p, attribute: .Top, multiplier: 1.0, constant: 20.0)])
            }
            
            _floatingView = fv
        }
        
        if let c = _cancelPreviousDelay {
            c()
        }
        _cancelPreviousDelay = delay(floatingViewTimeout) {
            if let (_, lifeTotal) = self._history.last {
                self._baseline = lifeTotal
            }
            self._history.removeAll(keepCapacity: true)
            
            if let fv = self._floatingView {
                UIView.animateWithDuration(self.floatingViewHideTime,
                                           animations: { fv.alpha = 0.0 },
                                           completion: { _ in fv.removeFromSuperview() })
                
                self._floatingView = nil
            }
        }
    }
}
