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
            let newColor = color + Int(translation.x / horizontalPanDivisor)
            if newColor < 0 { // wrap
                color = 4
            } else if newColor > 4 {
                color = 0
            } else {
                color = newColor
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
    
    var color:Int {
        get{ return backgroundView.color }
        set(value) {
            backgroundView.color = value
            
            if(value == 0) {
                textColor = UIColor.darkGrayColor()
            } else {
                textColor = UIColor.whiteColor()
            }
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
        color = Int(unbiasedRandom(5)) // likely to get overwritten by config load
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setConstraintsFor(toInterfaceOrientation)
        view.setNeedsDisplay()
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        view.removeConstraints(view.constraints())
        
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
    var _lifeTotal = 0 // do not access directly
    var _isUpsideDown = false // do not access directly
}

class PlayerBackgroundView : UIView {
    var _color1:UIColor = UIColor.blueColor()
    var _color2:UIColor = UIColor.blueColor()
    var _color:Int = 0 // white?
    
    var color:Int {
        get{ return _color }
        set(value) {
            _color = value
            setBackgroundToColor(value)
        }
    }
    
    class func lighterColor(c:UIColor) -> UIColor {
        var h:CGFloat = 0,
        s:CGFloat = 0,
        b:CGFloat = 0,
        a:CGFloat = 0;
        
        if c.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return c
    }
    
    func setBackgroundToColor(value:Int) {
        switch(value) {
        case 0: // WHITE - todo make the text black?
            _color1 = UIColor(red: 0.7, green: 0.68, blue: 0.66, alpha: 1)
            _color2 = UIColor(red: 0.8, green: 0.77, blue: 0.73, alpha: 1)
        case 1: // BLUE
            _color1 = UIColor(red: 0.0, green: 0.22, blue: 0.42, alpha: 1)
            _color2 = UIColor(red: 0.3, green: 0.50, blue: 1.00, alpha: 1)
        case 2: // BLACK
            _color1 = UIColor(red: 0.12, green: 0.19, blue: 0.25, alpha: 1)
            _color2 = UIColor(red: 0.05, green: 0.09, blue: 0.08, alpha: 1)
        case 3: // RED
            _color1 = UIColor(red: 0.34, green: 0.04, blue: 0.07, alpha: 1)
            _color2 = UIColor(red: 0.78, green: 0.14, blue: 0.04, alpha: 1)
        case 4: // GREEN
            _color1 = UIColor(red: 0.15, green: 0.38, blue: 0.27, alpha: 1)
            _color2 = UIColor(red: 0.19, green: 0.66, blue: 0.20, alpha: 1)
        default:
            break
        }
        
        self.setNeedsDisplay()
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
        let w = self.frame.size.width;
        
        let startPoint = CGPoint(x: w * -0.33, y: w * -0.33)
        
        //End point
        let endPoint = CGPoint(x: 0, y: 0)
        
        //Generate the Image -----------------------
        CGContextDrawRadialGradient(context, gradient, startPoint, 0, endPoint, w * 0.8, 0)
        
        CGContextRestoreGState(context);

    }
}