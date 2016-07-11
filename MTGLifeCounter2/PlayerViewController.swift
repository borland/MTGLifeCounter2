//
//  PlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum DisplaySize {
    case Small, Normal
}

enum ButtonOrientation {
    case Auto, Horizontal, Vertical
}

class PlayerViewController : UIViewController {
    private let _tracker = LifeTotalDeltaTracker()
    
    private var _xConstraint: NSLayoutConstraint?
    private var _yConstraint: NSLayoutConstraint?
    
    @IBOutlet var backgroundView: PlayerBackgroundView!
    @IBOutlet weak var lifeTotalLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    @IBAction func plusButtonPressed(sender: AnyObject) {
        lifeTotal += 1
    }
    
    @IBAction func minusButtonPressed(sender: AnyObject) {
        lifeTotal -= 1
    }
    
    @IBAction func lifeTotalPanning(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        let verticalPanDivisor:CGFloat = 10.0
        if translation.y < -verticalPanDivisor || translation.y > verticalPanDivisor { // vertical pan greater than threshold
            lifeTotal -= Int(translation.y / verticalPanDivisor)
            sender.setTranslation(CGPointMake(0,0), inView: view) // reset the recognizer
        }
        
        let horizontalPanDivisor:CGFloat = 30.0
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
        switch resolveButtonOrientation() {
        case .Horizontal: // buttons on sides
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
        
        let location = sender.locationInView(topView)
        let x = min(topView.frame.width - size, max(0, location.x - half))
        let y = min(topView.frame.height - size, max(20, location.y - half))
        
        let closePicker:(RadialColorPicker -> Void) = { picker in
            self._currentColorPicker = nil
            UIView.animateWithDuration(
                0.2,
                animations: { picker.alpha = 0.0 },
                completion: { _ in picker.removeFromSuperview() })
        }
        
        let picker = RadialColorPicker(frame: CGRectMake(x, y, size, size)) { picker, color in
            if let c = color { self.color = c }
            closePicker(picker)
        }
        _currentColorPicker = picker
        
        picker.alpha = 0.0
        topView.addSubview(picker)
        picker.becomeFirstResponder()
        
        UIView.animateWithDuration(0.2) { picker.alpha = 1.0 }
    }
    
    var buttonOrientation = ButtonOrientation.Auto
    
    var innerHorizontalOffset = CGFloat(0) {
        didSet {
            _xConstraint?.constant = innerHorizontalOffset
        }
    }
    
    var innerVerticalOffset = CGFloat(0) {
        didSet {
            _yConstraint?.constant = innerHorizontalOffset
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
            guard let l = lifeTotalLabel, plus = plusButton, minus = minusButton else { return }
            l.textColor = color
            plus.setTitleColor(color, forState: .Normal)
            minus.setTitleColor(color, forState: .Normal)
        }
    }
    
    var lifeTotal = 0 {
        didSet {
            _tracker.update(lifeTotal)
            
            if let x = lifeTotalLabel {
                x.text = "\(lifeTotal)"
            }
        }
    }
    
    func resetLifeTotal(lifeTotal:Int) {
        _tracker.reset(lifeTotal) // do this first to avoid "+0" flash on load
        self.lifeTotal = lifeTotal
    }
    
    func reset(lifeTotal lifeTotal:NSNumber?, color:NSNumber?) {
        if let lt = lifeTotal,
            let x = color,
            let col = MtgColor(rawValue: x.integerValue)
        {
            self.resetLifeTotal(lt.integerValue)
            self.color = col
        }
    }
    
    var displaySize: DisplaySize = .Normal {
        didSet {
            if let x = lifeTotalLabel {
                x.font = x.font.fontWithSize(displaySize == .Normal ? 120 : 80)
            }
            _tracker.floatingViewFontSize = displaySize == .Normal ? 44 : 30
        }
    }
    
    var isUpsideDown = false {
        didSet {
            if isUpsideDown {
                view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI));
            } else {
                view.transform = CGAffineTransformIdentity;
            }
        }
    }
    
    override func viewDidLoad() {
        setConstraintsFor(traitCollection)
        
        // trigger all the property change callbacks
        lifeTotal = self.lifeTotal + 0
        isUpsideDown = !(!self.isUpsideDown)
        displaySize = self.displaySize == .Normal ? .Normal : .Small
        
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
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(plusButton),
            constraints.affectingView(minusButton),
            constraints.affectingView(lifeTotalLabel))
        
        let views = ["view":view!, "plus":plusButton!, "minus":minusButton!, "lifeTotal":lifeTotalLabel!]
        
        _xConstraint = lifeTotalLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: innerHorizontalOffset)
        
        _yConstraint = lifeTotalLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: innerVerticalOffset)

        view.addConstraints([_xConstraint!, _yConstraint!])
        
        switch resolveButtonOrientation() {
        case .Horizontal: // +/- on the sides
            
            let hGap:CGFloat = displaySize == .Small ? 0 : 8 // in a horizontal star, pull the +/- buttons closer
            let metrics = ["hGap": hGap]
            
            view.addConstraints("H:[minus(44)]-(hGap)-[lifeTotal]-(hGap)-[plus(44)]", views: views, metrics: metrics)
            view.addConstraints([
                plusButton.centerYAnchor.constraintEqualToAnchor(lifeTotalLabel.centerYAnchor),
                minusButton.centerYAnchor.constraintEqualToAnchor(lifeTotalLabel.centerYAnchor),
            ])
            
        default: // +/- on the top/bottom
            
            let vGap:CGFloat = -16
            let metrics = ["vGap": vGap]
            
            view.addConstraints("V:[plus(44)]-(vGap)-[lifeTotal]-(vGap)-[minus(44)]", views: views, metrics: metrics)
            view.addConstraints([
                plusButton.centerXAnchor.constraintEqualToAnchor(lifeTotalLabel.centerXAnchor),
                minusButton.centerXAnchor.constraintEqualToAnchor(lifeTotalLabel.centerXAnchor),
                ])
        }
        
        view.setNeedsDisplay()
    }
    
    func resolveButtonOrientation() -> ButtonOrientation {
        switch buttonOrientation {
        case .Vertical:
            return .Vertical // explicitly set
        case .Horizontal:
            return .Horizontal // explicitly set
        case .Auto:
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.Compact, .Regular): // +/- on the sides
                return .Horizontal;
            default: // +/- on the top/bottom
                return .Vertical;
            }
        }
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