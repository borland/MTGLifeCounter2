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

class FloatingView : UIView {
    private var _isUpsideDown:Bool = false
    private let _wrapper:UIView
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
    required init(innerView:UIView) {
        _wrapper = UIView()
        _inner = innerView
        
        super.init(frame: CGRectMake(0,0,0,0))
    
        backgroundColor = UIColor.blueColor()
        
        _wrapper.setTranslatesAutoresizingMaskIntoConstraints(false)
        _wrapper.addSubview(innerView)
        _wrapper.addConstraints("H:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        _wrapper.addConstraints("V:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        _wrapper.sizeToFit()

        _wrapper.backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        _wrapper.alpha = 0.0
        _wrapper.layer.cornerRadius = 20
        _wrapper.clipsToBounds = true
        _wrapper.userInteractionEnabled = false

        addSubview(_wrapper)
        userInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init(coder aDecoder: NSCoder) {
        _wrapper = UIView()
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
                _wrapper.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI));
            } else {
                _wrapper.transform = CGAffineTransformIdentity;
            }
            
        default:
            assertionFailure("unhandled property")
        }
    }
    
    func showInView(parent: UIView, duration:Double){
        _wrapper.alpha = 1.0
        
        parent.addSubview(_wrapper)
        
        let views = ["parent":parent, "v":_wrapper]
        
        // Center
        parent.addConstraints([
            NSLayoutConstraint(item: _wrapper, attribute: .CenterX, relatedBy: .Equal, toItem: parent, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: _wrapper, attribute: .CenterY, relatedBy: .Equal, toItem: parent, attribute: .CenterY, multiplier: 1.0, constant: 0.0)])

        UIView.animateWithDuration(duration / 2,
            delay: duration / 2,
            options: .CurveEaseInOut,
            animations: { self._wrapper.alpha = 0 },
            completion: { (b:Bool) in
                self._wrapper.removeFromSuperview()
            })
    }
}