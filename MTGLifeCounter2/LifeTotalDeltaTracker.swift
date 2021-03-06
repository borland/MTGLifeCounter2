//
//  LifeTotalDeltaTracker.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 12/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum TrackerAttachPosition {
    case none // not shown
    case topLeft(NSLayoutYAxisAnchor, NSLayoutXAxisAnchor)
    case topRight(NSLayoutYAxisAnchor, NSLayoutXAxisAnchor)
    case bottomRight(NSLayoutYAxisAnchor, NSLayoutXAxisAnchor)
    case bottomLeft(NSLayoutYAxisAnchor, NSLayoutXAxisAnchor)
}

class LifeTotalDeltaTracker {
    
    /** How much time the delta tracker stays on screen before "committing" and going away */
    let floatingViewTimeout:TimeInterval = 2.5
    
    /** Animation time when the view fades out */
    let floatingViewHideTime:TimeInterval = 0.25
    
    private var _baseline = 0 // we show +/- x relative to this.
    private var _history = [(Date, Int)]()
    private var _floatingView:FloatingView?
    private let _label = UILabel()
    private var _cancelPreviousDelay:(()->())?
    
    init(fontSize: CGFloat = 44) {
        _label.font = UIFont(name:"Futura", size: 1)
        _label.textColor = UIColor.white
        _label.translatesAutoresizingMaskIntoConstraints = false
        
        floatingViewFontSize = fontSize
    }
    
    var floatingViewFontSize: CGFloat {
        didSet {
            _label.font = _label.font.withSize(floatingViewFontSize)
        }
    }
    
    var parent:UIView?
    var attachPosition: TrackerAttachPosition = .none
    var orientation: PlayerViewOrientation = .normal
    
    func update(_ lifeTotal:Int) {
        if let (_, lt) = _history.last {
            if lt == lifeTotal {
                return // no point recording a duplicate
            }
        }
        let tuple = (Date(), lifeTotal)
        _history.append(tuple)
        updateUi(lifeTotal)
    }
    
    func reset(_ lifeTotal:Int) {
        _history.removeAll(keepingCapacity: true)
        _baseline = lifeTotal
        updateUi(lifeTotal)
    }
    
    func updateUi(_ lifeTotal:Int) {
        let symbol = (lifeTotal - _baseline >= 0) ? "+" : "-"
        _label.text = "\(symbol)\(lifeTotal - _baseline)"
        _label.sizeToFit()
        showOrExtendView()
    }
    
    func showOrExtendView() {
        if let p = parent , _floatingView == nil && _history.count > 1 {
            let fv = FloatingView(innerView:self._label, cornerRadius: Float(floatingViewFontSize) / 5)
            
            fv.showInView(p) { floatingView in
                switch attachPosition {
                case .none:
                    break // view goes nowhere
                case .topLeft(let top, let left):
                    floatingView.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
                    floatingView.leftAnchor.constraint(equalTo: left, constant: 5).isActive = true
                case .topRight(let top, let right):
                    floatingView.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
                    floatingView.rightAnchor.constraint(equalTo: right, constant: 5).isActive = true
                case .bottomLeft(let bottom, let left):
                    floatingView.bottomAnchor.constraint(equalTo: bottom, constant: -20).isActive = true
                    floatingView.leftAnchor.constraint(equalTo: left, constant: -5).isActive = true
                case .bottomRight(let bottom, let right):
                    floatingView.bottomAnchor.constraint(equalTo: bottom, constant: -20).isActive = true
                    floatingView.rightAnchor.constraint(equalTo: right, constant: -5).isActive = true
                }
                
                switch orientation {
                case .normal:
                    break
                case .upsideDown: // no need to do anything, already handled
                    floatingView.transform = CGAffineTransform.identity.rotated(by: .pi)
                case .left:
                    floatingView.transform = CGAffineTransform.identity.rotated(by: .pi / 2)
                case .right:
                    floatingView.transform = CGAffineTransform.identity.rotated(by: -.pi / 2)
                }
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
            self._history.removeAll(keepingCapacity: true)
            
            if let fv = self._floatingView {
                UIView.animate(withDuration: self.floatingViewHideTime,
                                           animations: { fv.alpha = 0.0 },
                                           completion: { _ in fv.removeFromSuperview() })
                
                self._floatingView = nil
            }
        }
    }
}
