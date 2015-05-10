//
//  FloatingView.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 6/04/15.
//  Copyright (c) 2015 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

extension UIViewAutoresizing {
    static var FlexibleMargins: UIViewAutoresizing {
        get {
            return .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        }
    }
}

class DiceRollView {
    
    class func create(num:UInt) -> FloatingView {
        let attrs:[NSObject:AnyObject] = [NSUnderlineStyleAttributeName: NSNumber(int: 0x01)] // single underline
        let attributedText = (num == 6 || num == 9) ?
            NSAttributedString(string: "\(num)", attributes: attrs) :
            NSAttributedString(string: "\(num)")
        
        return FloatingView(text:attributedText, fontSize:120)
    }
}

class FloatingView : UIView {
    private var _isUpsideDown:Bool = false
    private let _inner:UIView

    // will create a uiLabel for text/fontSize, then wrap it in a rounded-rect border with 10px padding and center it in the frame
    convenience init(text:NSAttributedString, fontSize:CGFloat) {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textColor = UIColor.whiteColor()
        label.attributedText = text
        label.font = UIFont(name:"Futura", size:fontSize)
        label.textAlignment = .Center
        label.sizeToFit()
        
        self.init(innerView:label)
    }
    
    // will wrap innerView in a rounded-rect border with 10px padding and center it in the frame
    // the overall size will be determined by innerView's intrinsic size
    required init(innerView:UIView, cornerRadius:Float = 20) {
        _inner = innerView
        
        super.init(frame: CGRectMake(0,0,0,0))
    
        backgroundColor = UIColor.blueColor()
        
        setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(innerView)
        addConstraints("H:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        addConstraints("V:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        sizeToFit()

        backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        alpha = 0.0
        layer.cornerRadius = CGFloat(cornerRadius)
        clipsToBounds = true
        userInteractionEnabled = false

        userInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init(coder aDecoder: NSCoder) {
        _inner = UIView()
        super.init(coder: aDecoder)
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
        case "isUpsideDown":
            if _isUpsideDown {
                transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI));
            } else {
                transform = CGAffineTransformIdentity;
            }
            
        default:
            assertionFailure("unhandled property")
        }
    }
    
    func showInView(parent: UIView, setup: UIView -> ()) {
        alpha = 1.0
        
        parent.addSubview(self)
        
        setup(self)
    }
    
    func showInView(parent: UIView, duration:Double) {
        showInView(parent) { floatingView in
            // Center
            parent.addConstraints([
                NSLayoutConstraint(item: floatingView, attribute: .CenterX, relatedBy: .Equal, toItem: parent, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: floatingView, attribute: .CenterY, relatedBy: .Equal, toItem: parent, attribute: .CenterY, multiplier: 1.0, constant: 0.0)])
            
            UIView.animateWithDuration(duration / 2,
                delay: duration / 2,
                options: .CurveEaseInOut,
                animations: { floatingView.alpha = 0 },
                completion: { (b:Bool) in
                    floatingView.removeFromSuperview()
            })
        }
    }
}