//
//  PlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class LifeTotalDeltaTracker {
    let floatingViewFontSize = 44
    let floatingViewTimeout = 1.7
    let floatingViewHideTime = 0.25
    
    private var _baseline = 0 // we show +/- x relative to this.
    private var _history = [(NSDate, Int)]()
    private var _floatingView:FloatingView?
    private let _label = UILabel()
    private var _cancelPreviousDelay:(()->())?
    
    init () {
        _label.font = UIFont(name:"Futura", size:CGFloat(floatingViewFontSize))
        _label.textColor = UIColor.whiteColor()
        _label.translatesAutoresizingMaskIntoConstraints = false
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
            let fv = FloatingView(innerView:self._label, cornerRadius:Float(floatingViewFontSize) / 5)
            
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

class PlayerViewController : UIViewController {
    private let _tracker = LifeTotalDeltaTracker()
    
    @IBOutlet var backgroundView: PlayerBackgroundView!
    @IBOutlet weak var lifeTotalLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var playerNameButton: UIButton!
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        lifeTotal += 1
    }
    
    @IBAction func minusButtonPressed(sender: AnyObject) {
        lifeTotal -= 1
    }
    
    @IBAction func playerNamePressed(sender: AnyObject) {
    }
    
    @IBAction func lifeTotalPanning(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        let verticalPanDivisor:CGFloat = 7.0
        if translation.y < -verticalPanDivisor || translation.y > verticalPanDivisor { // vertical pan greater than threshold
            lifeTotal -= Int(translation.y / verticalPanDivisor)
            sender.setTranslation(CGPointMake(0,0), inView: view) // reset the recognizer
        }
        
        let horizontalPanDivisor:CGFloat = 20.0
        if translation.x < -horizontalPanDivisor || translation.x > horizontalPanDivisor { // horz pan greater than threshold
            let newColor = color.rawValue + Int(translation.x / horizontalPanDivisor)
            if newColor < MtgColor.First().rawValue { // wrap
                color = MtgColor.Last()
            } else if newColor > MtgColor.Last().rawValue {
                color = MtgColor.First()
            } else if let x = MtgColor(rawValue: newColor) {
                color = x
            }
            sender.setTranslation(CGPointMake(0,0), inView: view) // reset the recognizer
        }
    }
    
    @IBAction func lifeTotalWasTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(view)
        let reference = view.frame
        
        var up = true;
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            up = location.x > (reference.size.width / 2)
            
        default:
            up = location.y < (reference.size.height / 2)
        }
        
        if(up) {
            plusButtonPressed(sender)
        } else {
            minusButtonPressed(sender)
        }
    }
    
    private var _currentColorPicker:RadialColorPicker?
    
    @IBAction func viewWasLongPressed(sender: UILongPressGestureRecognizer) {
        if _currentColorPicker != nil {
            return
        }
        
        let topView = self.view.window! // MUST be on screen or crash means a bug
        let size = CGFloat(300)
        let half = size/2
        
        let lightboxBackground = UIView(frame: topView.frame)
        lightboxBackground.backgroundColor = UIColor(white: 0, alpha: 1)
        
        let location = sender.locationInView(topView)
        let x = min(topView.frame.width - size, max(0, location.x - half))
        let y = min(topView.frame.height - size, max(20, location.y - half))
        
        let closePicker:(RadialColorPicker -> Void) = { picker in
            self._currentColorPicker = nil
            UIView.animateWithDuration(
                0.2,
                animations: {
                    lightboxBackground.alpha = 0.0
                    picker.alpha = 0.0
                },
                completion: { _ in
                    picker.removeFromSuperview()
                    lightboxBackground.removeFromSuperview()
            })
        }
        
        let picker = RadialColorPicker(frame: CGRectMake(x, y, size, size)) { picker, color in
            if let c = color { self.color = c }
            closePicker(picker)
        }
        _currentColorPicker = picker
        
        lightboxBackground.alpha = 0.0
        picker.alpha = 0.0
        topView.addSubview(lightboxBackground)
        topView.addSubview(picker)
        picker.becomeFirstResponder()
        
        UIView.animateWithDuration(0.2) {
            lightboxBackground.alpha = 0.3
            picker.alpha = 1.0
        }
    }
    
    var color = MtgColor.White {
        didSet {
            backgroundView.setBackgroundToColors(color)
            
            if(color == MtgColor.White) {
                textColor = UIColor(red: 0.2, green:0.2, blue:0.2, alpha:1.0)
            } else {
                textColor = UIColor.whiteColor()
            }
            
            backgroundView.addLabel(color.displayName, isUpsideDown: isUpsideDown, textColor: textColor)
        }
    }
    
    var textColor:UIColor {
        get {
            if let x = lifeTotalLabel {
                return x.textColor
            }
            return UIColor.whiteColor()
        }
        set(color) {
            guard let l = lifeTotalLabel, plus = plusButton, minus = minusButton, name = playerNameButton else { return }
            l.textColor = color
            plus.setTitleColor(color, forState: .Normal)
            minus.setTitleColor(color, forState: .Normal)
            name.setTitleColor(color, forState: .Normal)
        }
    }
    
    var playerName = "" {
        didSet {
            propertyDidChange("playerName")
        }
    }
    
    var lifeTotal = 0 {
        didSet {
            _tracker.update(lifeTotal)
            propertyDidChange("lifeTotal")
        }
    }
    
    func resetLifeTotal(lifeTotal:Int) {
        self.lifeTotal = lifeTotal
        _tracker.reset(lifeTotal)
        propertyDidChange("lifeTotal")
    }
    
    var isUpsideDown = false {
        didSet {
            propertyDidChange("isUpsideDown")
        }
    }
    
    func propertyDidChange(propertyName:String) {
        switch(propertyName) {
        case "lifeTotal":
            if let x = lifeTotalLabel {
                x.text = "\(lifeTotal)"
            }
        case "playerName":
            if let x = playerNameButton {
                x.setTitle(playerName, forState: .Normal)
            }
            
        case "isUpsideDown":
            if isUpsideDown {
                view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI));
            } else {
                view.transform = CGAffineTransformIdentity;
            }

        default:
            assertionFailure("unhandled property")
        }
    }
    
    override func viewDidLoad() {
        setConstraintsFor(traitCollection)
        
        propertyDidChange("playerName")
        propertyDidChange("lifeTotal")
        propertyDidChange("isUpsideDown")
        
        let maxColorNum = UInt32(MtgColor.Last().rawValue)
        if let x = MtgColor(rawValue: Int(arc4random_uniform(maxColorNum))) {
            color = x  // likely to get overwritten by config load
        }

        _tracker.parent = view // now the tracker can use the parent
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraintsFor(traitCollection)
    }
    
    func setConstraintsFor(traitCollection:UITraitCollection) {
        let cx = view.constraints as [NSLayoutConstraint]
        view.removeConstraints(
            constraints(cx, affectingView:plusButton) +
            constraints(cx, affectingView:minusButton) +
            constraints(cx, affectingView:lifeTotalLabel) +
            constraints(cx, affectingView:playerNameButton))
        
        let views = ["view":view!, "plus":plusButton!, "minus":minusButton!, "lifeTotal":lifeTotalLabel!, "playerName":playerNameButton!]
        
        view.addConstraints("H:[view]-(<=1)-[lifeTotal]", views: views, options: .AlignAllCenterY)
        view.addConstraints("V:[view]-(<=1)-[lifeTotal]", views: views, options: .AlignAllCenterX)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // +/- on the sides
            view.addConstraints("H:|-6-[playerName]", views: views)
            view.addConstraints("V:|-10-[playerName]", views: views)
            
            view.addConstraints("H:[plus(44)]-|", views: views)
            view.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))

            view.addConstraints("H:|-[minus(44)]", views: views)
            view.addConstraint(NSLayoutConstraint(item: minusButton, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
            
        default: // +/- on the top/bottom
            view.addConstraints("H:|-6-[playerName]", views: views)
            view.addConstraints("V:|-30-[playerName]", views: views)
            
            view.addConstraints("V:|-40-[plus(44)]", views: views)
            view.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
            view.addConstraints("V:[minus(44)]-40-|", views: views)
            view.addConstraint(NSLayoutConstraint(item: minusButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        }
        
        view.setNeedsDisplay()
    }
}

class PlayerBackgroundView : UIView {
    private var _color1:UIColor = UIColor.blueColor()
    private var _color2:UIColor = UIColor.blueColor()
    private var _lastLabel:UILabel? = nil
    
    func setBackgroundToColors(color:MtgColor) {
        _color1 = color.lookup(true)
        _color2 = color.lookup(false)
        
        self.setNeedsDisplay()
    }
    
    func addLabel(text:String, isUpsideDown:Bool, textColor:UIColor) {
        let labelHeight = CGFloat(20)
        let labelTopOffset = CGFloat(20)
        let label = UILabel(frame:
            CGRectMake(0, labelTopOffset, frame.width, labelHeight))
        
        label.font = UIFont.boldSystemFontOfSize(14.0)
        label.textAlignment = .Center
        label.text = text
        label.textColor = textColor
        
        if let last = _lastLabel {
            last.removeFromSuperview()
        }
        _lastLabel = label
        
        addSubview(label)
        UIView.animateWithDuration(0.5,
            delay:0,
            options:UIViewAnimationOptions.CurveEaseInOut,
            animations:{ label.alpha = 0 },
            completion:{ _ in label.removeFromSuperview() })
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        let c1 = CGColorGetComponents(_color1.CGColor)
        let c2 = CGColorGetComponents(_color2.CGColor)
        
        // draw a flat background rectangle as the gradient doesn't "keep going"
        CGContextSetFillColor(context, c2)
        CGContextFillRect(context, rect)
        
        //Define the gradient ----------------------
        let locations:[CGFloat] = [0.0, 1.0];
        
        let components:[CGFloat] = [c1.memory, (c1+1).memory,(c1+2).memory,(c1+3).memory,
            c2.memory, (c2+1).memory,(c2+2).memory,(c2+3).memory ]

        let colorSpace = CGColorSpaceCreateDeviceRGB();

        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locations.count);
        
        //Define Gradient Positions ---------------
        
        //Start point
        let sz = max(frame.size.width, frame.size.height) * 1.3
        
        let startCenter = CGPoint(x: 0, y: 0)
        let startRadius = CGFloat(0)
        
        //End point
        let endCenter = startCenter // must be the same for a simple circle gradient
        let endRadius = CGFloat(sz)
        
        let options = CGGradientDrawingOptions(rawValue: 0)
        
        //Generate the Image -----------------------
        CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, options)

        CGContextRestoreGState(context);

    }
}