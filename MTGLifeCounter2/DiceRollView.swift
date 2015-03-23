//
//  DiceRollView.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 6/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
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

class DiceRollView : UIView {
    private var _isUpsideDown:Bool = false
    private let _label:UILabel
    private let _faceCount:UInt
    
    required init(frame:CGRect, faceCount:UInt = 20) {
        _faceCount = faceCount
        
        let labelHeight = 180.0
        let labelWidth = 180.0
        
        let centerX = Double(frame.size.width / 2.0)
        let centerY = Double(frame.size.height / 2.0)
        
        // create and configure the label
        let rect = CGRectMake(
            CGFloat(centerX - (labelWidth / 2.0)),
            CGFloat(centerY - (labelHeight / 2.0)),
            CGFloat(labelWidth),
            CGFloat(labelHeight))
        
        _label = UILabel(frame: rect)
        
        super.init(frame:frame)
        
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        _label.backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        _label.alpha = 1.0
        _label.textColor = UIColor.whiteColor()
        _label.text = nil
        _label.font = UIFont(name:"Futura", size:120)
        _label.textAlignment = .Center
        _label.autoresizingMask = .FlexibleMargins
        _label.layer.cornerRadius = 20
        _label.clipsToBounds = true
        _label.userInteractionEnabled = false
        
        self.addSubview(_label)
        self.userInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init(coder aDecoder: NSCoder) {
        _label = UILabel()
        _faceCount = 0
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
                _label.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI));
            } else {
                _label.transform = CGAffineTransformIdentity;
            }
            
        default:
            assertionFailure("unhandled property")
        }
    }
    
    func roll(#duration:Double, completion:(Bool -> Void)){
        let n = arc4random_uniform(UInt32(_faceCount)) + 1
        
        let attrs:[NSObject:AnyObject] = [NSUnderlineStyleAttributeName: NSNumber(int: 0x01)] // single underline
        _label.attributedText = (n == 6 || n == 9) ?
            NSAttributedString(string: "\(n)", attributes: attrs) :
            NSAttributedString(string: "\(n)")
        
        UIView.animateWithDuration(duration / 2,
            delay:duration / 2,
            options:.CurveEaseInOut,
            animations:{ self._label.alpha = 0 },
            completion: completion)
    }
}