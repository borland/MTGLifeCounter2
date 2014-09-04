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