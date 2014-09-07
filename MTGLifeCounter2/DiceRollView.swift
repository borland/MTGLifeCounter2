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
    let label:UILabel
    let faceCount:UInt
    
    required init(frame:CGRect, faceCount:UInt = 20) {
        self.faceCount = faceCount
        
        let labelHeight = 160.0
        let labelWidth = 160.0
        
        let centerX = Double(frame.size.width / 2.0)
        let centerY = Double(frame.size.height / 2.0)
        
        // create and configure the label
        let rect = CGRectMake(
            CGFloat(centerX - (labelWidth / 2.0)),
            CGFloat(centerY - (labelHeight / 2.0)),
            CGFloat(labelWidth),
            CGFloat(labelHeight))
        
        label = UILabel(frame: rect)
        
        super.init(frame:frame)
        
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        label.backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        label.alpha = 1.0
        label.textColor = UIColor.whiteColor()
        label.text = nil
        label.font = UIFont(name:"Futura", size:100)
        label.textAlignment = .Center
        label.autoresizingMask = .FlexibleMargins
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.userInteractionEnabled = false
        
        self.addSubview(label)
        self.userInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init(coder aDecoder: NSCoder) {
        self.label = UILabel()
        self.faceCount = 0
        super.init(coder: aDecoder)
    }
    
    func roll(#completion:(Bool -> Void)){
        let n = unbiasedRandom(Int32(faceCount)) + 1
        
        let attrs:[NSObject:AnyObject] = [NSUnderlineStyleAttributeName: NSNumber(int: 0x01)] // single underline
        var ats = NSAttributedString(string:"\(n)", attributes: attrs)
        label.attributedText = ats
        
        UIView.animateWithDuration(1.7,
            delay:0,
            options:.CurveEaseInOut,
            animations:{ self.label.alpha = 0 },
            completion: completion)
    }
}