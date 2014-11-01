//
//  PlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class PlayerViewController : UIViewController {
    
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
            } else {
                if let x = MtgColor(rawValue: newColor) {
                    color = x
                }
            }
            sender.setTranslation(CGPointMake(0,0), inView: view) // reset the recognizer
        }
    }
    
    @IBAction func lifeTotalWasTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(view)
        let reference = view.frame
        
        var up = true;
        switch interfaceOrientation {
        case .Unknown, .Portrait, .PortraitUpsideDown:
            up = location.x > (reference.size.width / 2)
            
        case .LandscapeLeft, .LandscapeRight:
            up = location.y < (reference.size.height / 2)
        }
        
        if(up) {
            plusButtonPressed(sender)
        } else {
            minusButtonPressed(sender)
        }
    }
    
    var color:MtgColor {
        get{ return _color }
        set(value) {
            _color = value
            backgroundView.setBackgroundToColors(value)
            
            if(value == MtgColor.White) {
                textColor = UIColor(red: 0.2, green:0.2, blue:0.2, alpha:1.0)
            } else {
                textColor = UIColor.whiteColor()
            }
            
            backgroundView.addLabel(value.displayName, isUpsideDown: isUpsideDown, textColor: textColor)
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
            if let x = lifeTotalLabel {
                x.textColor = color
            }
            if let x = plusButton {
                x.setTitleColor(color, forState: .Normal)
            }
            if let x = minusButton {
                x.setTitleColor(color, forState: .Normal)
            }
            if let x = playerNameButton {
                x.setTitleColor(color, forState: .Normal)
            }
        }
    }
    
    var playerName:String {
        get{ return _playerName }
        set(value) {
            _playerName = value
            propertyDidChange("playerName")
        }
    }
    
    var lifeTotal:Int {
        get { return _lifeTotal }
        set(value) {
            _lifeTotal = value
            propertyDidChange("lifeTotal")
        }
    }
    
    var isUpsideDown:Bool {
        get{ return _isUpsideDown }
        set(value) {
            _isUpsideDown = value
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
        setConstraintsFor(interfaceOrientation)
        
        propertyDidChange("playerName")
        propertyDidChange("lifeTotal")
        propertyDidChange("isUpsideDown")
        
        let maxColorNum = UInt32(MtgColor.Last().rawValue)
        if let x = MtgColor(rawValue: Int(arc4random_uniform(maxColorNum))) {
            color = x  // likely to get overwritten by config load
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setConstraintsFor(toInterfaceOrientation)
        view.setNeedsDisplay()
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        let cx = view.constraints() as [NSLayoutConstraint]
        view.removeConstraints(
            constraints(cx, affectingView:plusButton) +
            constraints(cx, affectingView:minusButton) +
            constraints(cx, affectingView:lifeTotalLabel) +
            constraints(cx, affectingView:playerNameButton))
        
        let views = ["view":view, "plus":plusButton, "minus":minusButton, "lifeTotal":lifeTotalLabel, "playerName":playerNameButton]
        
        view.addConstraints("H:[view]-(<=1)-[lifeTotal]", views: views, options: .AlignAllCenterY)
        view.addConstraints("V:[view]-(<=1)-[lifeTotal]", views: views, options: .AlignAllCenterX)

        
        switch (orientation) {
        case .Unknown, .Portrait, .PortraitUpsideDown: // +/- on the sides
            view.addConstraints("H:|-6-[playerName]", views: views)
            view.addConstraints("V:|-10-[playerName]", views: views)
            
            view.addConstraints("H:[plus(44)]-|", views: views)
            view.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))

            view.addConstraints("H:|-[minus(44)]", views: views)
            view.addConstraint(NSLayoutConstraint(item: minusButton, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
            
        case .LandscapeLeft, .LandscapeRight: // +/- on the top/bottom
            view.addConstraints("H:|-6-[playerName]", views: views)
            view.addConstraints("V:|-30-[playerName]", views: views)
            
            view.addConstraints("V:|-40-[plus(44)]", views: views)
            view.addConstraint(NSLayoutConstraint(item: plusButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
            view.addConstraints("V:[minus(44)]-40-|", views: views)
            view.addConstraint(NSLayoutConstraint(item: minusButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        }
    }
    
private
    var _playerName = ""
    var _lifeTotal = 0
    var _isUpsideDown = false
    var _color:MtgColor = MtgColor.White
}

class PlayerBackgroundView : UIView {
    var _color1:UIColor = UIColor.blueColor()
    var _color2:UIColor = UIColor.blueColor()
    var _lastLabel:UILabel? = nil
    
    func setBackgroundToColors(color:MtgColor) {
        _color1 = color.lookup(true)
        _color2 = color.lookup(false)
        
        self.setNeedsDisplay()
    }
    
    func addLabel(text:String, isUpsideDown:Bool, textColor:UIColor) {
        let labelHeight = CGFloat(20)
        let labelBottomOffset = isUpsideDown ? CGFloat(20) : CGFloat(0)
        let label = UILabel(frame:
            CGRectMake(0, frame.height-labelHeight-labelBottomOffset, frame.width, labelHeight))
        
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
        
        let components:[CGFloat] = [
            c1.memory, (c1+1).memory,(c1+2).memory,(c1+3).memory,
            c2.memory, (c2+1).memory,(c2+2).memory,(c2+3).memory ]

        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let gradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, UInt(locations.count));
        
        //Define Gradient Positions ---------------
        
        //Start point
        let sz = max(frame.size.width, frame.size.height) * 1.3
        
        let startCenter = CGPoint(x: 0, y: 0)
        let startRadius = CGFloat(0)
        
        //End point
        let endCenter = startCenter // must be the same for a simple circle gradient
        let endRadius = CGFloat(sz)
        
        let options = CGGradientDrawingOptions(0)
        
        //Generate the Image -----------------------
        CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, options)
        
        CGContextRestoreGState(context);

    }
}