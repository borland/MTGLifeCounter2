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
    var playerName:String = ""
    var lifeTotal:Int = 0
    var isUpsideDown:Bool = false
    
    func selectRandomColor() {
        if let bg = backgroundView {
            bg.selectRandomColor()
        }
    }
    
    @IBOutlet var backgroundView: PlayerBackgroundView!
    @IBOutlet weak var lifeTotalLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var playerNameButton: UIButton!
    
    override func viewDidLoad() {
        setConstraintsFor(interfaceOrientation)
        
        if isUpsideDown {
            view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)
        }
        
//        [self addObserver:self forKeyPath:@"lifeTotal" options:NSKeyValueObservingOptionNew context:nil];
//        [self addObserver:self forKeyPath:@"playerName" options:NSKeyValueObservingOptionNew context:nil];
//        [self addObserver:self forKeyPath:@"isUpsideDown" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        view.removeConstraints(view.constraints())
        
        let views:[NSString:AnyObject] = ["view":view, "plus":plusButton, "minus":minusButton, "lifeTotal":lifeTotalLabel, "playerName":playerNameButton]
        
        let addConstraintsWithOptions = { format, options in
            self.view.addConstraints(
                NSLayoutConstraint .constraintsWithVisualFormat(format, options: options, metrics: nil, views: views))
        }
        
        let addConstraints = { format in addConstraintsWithOptions(format, NSLayoutFormatOptions.AlignAllLeft) }
        
        addConstraintsWithOptions("H:[view]-(<=1)-[lifeTotal]", NSLayoutFormatOptions.AlignAllCenterY)
        addConstraintsWithOptions("V:[view]-(<=1)-[lifeTotal]", NSLayoutFormatOptions.AlignAllCenterX)
        
        switch(orientation) {
        case .Unknown, .Portrait, .PortraitUpsideDown: // the plus/minus buttons go on the left/right
            addConstraints("H:|-6-[playerName]")
            addConstraints("V:|-6-[playerName]")
            
            addConstraintsWithOptions("H:[plus(44)]-|", NSLayoutFormatOptions.AlignAllCenterY
        }

    
    switch (orientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationPortraitUpsideDown: // +/- on the sides

        // keep porting here!
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"H:[plus(44)]-|" options:0 metrics:nil views:views]);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:plus attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[minus(44)]" options:0 metrics:nil views:views]);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:minus attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    break;
    
    case UIInterfaceOrientationLandscapeLeft: // +/- on the top/bottom
    case UIInterfaceOrientationLandscapeRight:
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[playerName]" options:0 metrics:nil views:views]);
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[playerName]" options:0 metrics:nil views:views]);
    
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[plus(44)]" options:0 metrics:nil views:views]);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:plus attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    addConstraints([NSLayoutConstraint constraintsWithVisualFormat:@"V:[minus(44)]-|" options:0 metrics:nil views:views]);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:minus attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    break;
    default:
    break;
    }
    }
}

class PlayerBackgroundView : UIView {
    var _color1:UIColor = UIColor.blueColor()
    var _color2:UIColor = UIColor.blueColor()
    
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
    
    func selectRandomColor() {
        switch(unbiasedRandom(5)) {
        case 0: // WHITE
            _color1 = UIColor(red: 0.7, green: 0.68, blue: 0.66, alpha: 1)
            _color2 = UIColor(red: 0.8, green: 0.77, blue: 0.73, alpha: 1)
        case 1: // BLUE
            _color1 = UIColor(red: 0.0, green: 0.22, blue: 0.42, alpha: 1)
            _color2 = UIColor(red: 0.6, green: 0.80, blue: 0.10, alpha: 1)
        case 2: // BLACK
            _color1 = UIColor(red: 0.12, green: 0.19, blue: 0.25, alpha: 1)
            _color2 = UIColor(red: 0.25, green: 0.29, blue: 0.28, alpha: 1)
        case 3: // RED
            _color1 = UIColor(red: 0.34, green: 0.04, blue: 0.07, alpha: 1)
            _color2 = UIColor(red: 0.88, green: 0.44, blue: 0.34, alpha: 1)
        case 4: // GREEN
            _color1 = UIColor(red: 0.15, green: 0.38, blue: 0.27, alpha: 1)
            _color2 = UIColor(red: 0.39, green: 0.66, blue: 0.40, alpha: 1)
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
        let locations_num:size_t = 2;
        
        let locations:[CGFloat] = [0.0, 1.0];
        
        let components:[CGFloat] = [0, 0, 0, 0,  0,0,0,0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let gradient = CGGradientCreateWithColorComponents (colorSpace, components,
            locations, locations_num);
        
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