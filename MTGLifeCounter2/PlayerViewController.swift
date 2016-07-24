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

enum PlusMinusButtonPosition {
    case Auto, Sides, TopBottom
}

enum ViewOrientation {
    case Normal, UpsideDown, Left, Right
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
        let translation = sender.translationInView(backgroundView)
        
        let verticalPanDivisor:CGFloat = 10.0
        if translation.y < -verticalPanDivisor || translation.y > verticalPanDivisor { // vertical pan greater than threshold
            lifeTotal -= Int(translation.y / verticalPanDivisor)
            sender.setTranslation(CGPointMake(0,0), inView: backgroundView) // reset the recognizer
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
            sender.setTranslation(CGPointMake(0,0), inView: backgroundView) // reset the recognizer
        }
    }
    
    @IBAction func lifeTotalWasTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(backgroundView)
        let reference = backgroundView.frame
        
        var up = true;
        switch resolveButtonPosition() {
        case .Sides:
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
        
        let radialHostView = RadialHostView.locate(sender.view!)
        
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
                completion: { _ in
                    picker.removeFromSuperview()
                    radialHostView?.activePicker = nil
            })
        }
        
        let picker = RadialColorPicker(frame: CGRectMake(x, y, size, size)) { picker, color in
            if let c = color { self.color = c }
            closePicker(picker)
        }
        _currentColorPicker = picker
        radialHostView?.activePicker = picker
        
        picker.alpha = 0.0
        topView.addSubview(picker)
        picker.becomeFirstResponder()
        
        UIView.animateWithDuration(0.2) { picker.alpha = 1.0 }
    }
    
    var buttonPosition = PlusMinusButtonPosition.Auto
    
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
            backgroundView.addLabel(color.displayName, isUpsideDown: false, textColor: textColor)
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
    
    var orientation: ViewOrientation = .Normal {
        didSet {
            switch orientation {
            case .UpsideDown:
                backgroundView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI))
            case .Left:
                backgroundView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI_2))
            case .Right:
                backgroundView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(-M_PI_2))
            case .Normal:
                backgroundView.transform = CGAffineTransformIdentity;
            }
        }
    }
    
    override func viewDidLoad() {
        setConstraintsFor(traitCollection)
        
        // trigger all the property change callbacks
        lifeTotal = self.lifeTotal + 0
        orientation = self.orientation == .Normal ? .Normal : self.orientation
        displaySize = self.displaySize == .Normal ? .Normal : .Small
        
        let maxColorNum = UInt32(MtgColor.Last().rawValue)
        if let x = MtgColor(rawValue: Int(arc4random_uniform(maxColorNum))) {
            color = x  // likely to get overwritten by config load
        }

        _tracker.parent = backgroundView // now the tracker can use the parent
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraintsFor(traitCollection)
    }
    
    func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = backgroundView.constraints as [NSLayoutConstraint]
        backgroundView.removeAllConstraints(
            constraints.affectingView(plusButton),
            constraints.affectingView(minusButton),
            constraints.affectingView(lifeTotalLabel))
        
        let views = ["view":backgroundView!, "plus":plusButton!, "minus":minusButton!, "lifeTotal":lifeTotalLabel!]
        
        _xConstraint = lifeTotalLabel.centerXAnchor.constraintEqualToAnchor(backgroundView.centerXAnchor, constant: innerHorizontalOffset)
        
        _yConstraint = lifeTotalLabel.centerYAnchor.constraintEqualToAnchor(backgroundView.centerYAnchor, constant: innerVerticalOffset)

        backgroundView.addConstraints([_xConstraint!, _yConstraint!])
        
        switch resolveButtonPosition() {
        case .Sides: // +/- on the sides
            
            let hGap:CGFloat = displaySize == .Small ? 0 : 8 // in a horizontal star, pull the +/- buttons closer
            let metrics = ["hGap": hGap]
            
            backgroundView.addConstraints("H:[minus(44)]-(hGap)-[lifeTotal]-(hGap)-[plus(44)]", views: views, metrics: metrics)
            backgroundView.addConstraints([
                plusButton.centerYAnchor.constraintEqualToAnchor(lifeTotalLabel.centerYAnchor),
                minusButton.centerYAnchor.constraintEqualToAnchor(lifeTotalLabel.centerYAnchor),
            ])
            
        default: // +/- on the top/bottom
            
            let vGap:CGFloat = -16
            let metrics = ["vGap": vGap]
            
            backgroundView.addConstraints("V:[plus(44)]-(vGap)-[lifeTotal]-(vGap)-[minus(44)]", views: views, metrics: metrics)
            backgroundView.addConstraints([
                plusButton.centerXAnchor.constraintEqualToAnchor(lifeTotalLabel.centerXAnchor),
                minusButton.centerXAnchor.constraintEqualToAnchor(lifeTotalLabel.centerXAnchor),
                ])
        }
        
        backgroundView.setNeedsDisplay()
    }
    
    func resolveButtonPosition() -> PlusMinusButtonPosition {
        switch buttonPosition {
        case .TopBottom, .Sides:
            return buttonPosition // explicitly set
        case .Auto:
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.Compact, .Regular): // +/- on the sides
                return .Sides;
            default:
                return .TopBottom;
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

@IBDesignable class RotationContainerView: UIView {
    var child: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
//        
//        rotationView.backgroundColor = UIColor.redColor()
//        textView.backgroundColor = UIColor.yellowColor()
//        self.addSubview(rotationView)
//        rotationView.addSubview(textView)
//        
//        // could also do this with auto layout constraints
//        textView.frame = rotationView.bounds
    }
    
    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        rotationView.transform = CGAffineTransformIdentity // *** key line ***
//        
//        rotationView.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.bounds.height, height: self.bounds.width))
//        rotationView.transform = translateRotateFlip()
    }
    
    func translateRotateFlip() -> CGAffineTransform {
        
        var transform = CGAffineTransformIdentity
        
        // translate to new center
        transform = CGAffineTransformTranslate(transform, (self.bounds.width / 2)-(self.bounds.height / 2), (self.bounds.height / 2)-(self.bounds.width / 2))
        // rotate counterclockwise around center
        transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        // flip vertically
        transform = CGAffineTransformScale(transform, -1, 1)
        
        return transform
    }
}