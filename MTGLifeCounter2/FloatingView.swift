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
            return [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        }
    }
}

class DiceRollView {
    
    class func create(num:UInt, winner:Bool) -> FloatingView {
        let singleUnderline:[String:AnyObject] = [NSUnderlineStyleAttributeName: NSNumber(int: 1)]
        
        let generator = { (x:Int) -> NSAttributedString in
            if x == 0 {
                if (num == 6 || num == 9) {
                    return NSAttributedString(string: "\(num)", attributes: singleUnderline)
                } else {
                    return NSAttributedString(string: "\(num)")
                }
            }
            
            return NSAttributedString(string: "\(arc4random_uniform(20) + 1)") // don't underline values that aren't the result, it looks bad
        }
        
        let numberView = NumberWheelView(fontSize: 110, textColor: UIColor.whiteColor(), numCells:30, generator: generator)
        let widthConstraint = NSLayoutConstraint(item: numberView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 135)
        let heightConstraint = NSLayoutConstraint(item: numberView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 125)

        numberView.addConstraints([widthConstraint, heightConstraint])

        let fv = FloatingView(innerView: numberView, cornerRadius: 120 / 5)
        fv.beforeShow = { numberView.spinWithDuration($0 - 0.25) }
        fv.beforePause = {
            if winner {
                // gold
                fv.backgroundColor = UIColor(red:0.988, green:0.761, blue:0, alpha:1.0)
                let duration = 0.1
                let initialTransform = fv.transform

                UIView.animateWithDuration(duration, delay: 0, options: .Autoreverse,
                    animations: {
                        fv.transform = CGAffineTransformConcat(initialTransform, CGAffineTransformMakeScale(1.2, 1.2))
                    }, completion: { _ in
                        fv.transform = initialTransform
                        // this is how we "repeat" one time
                        UIView.animateWithDuration(duration, delay: 0, options: .Autoreverse,
                            animations: {
                                fv.transform = CGAffineTransformConcat(initialTransform, CGAffineTransformMakeScale(1.2, 1.2))
                            }, completion: { _ in
                                fv.transform = initialTransform
                        })

                })
            }
        }
        return fv
    }
}

class FloatingView : UIView {
    private var _isUpsideDown:Bool = false
    private let _inner:UIView

    // will create a uiLabel for text/fontSize, then wrap it in a rounded-rect border with 10px padding and center it in the frame
    convenience init(text:NSAttributedString, fontSize:CGFloat) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerView)
        addConstraints("H:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        addConstraints("V:|-[inner]-|", views: ["inner":innerView], options: .AlignAllBaseline)
        sizeToFit()

        backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        alpha = 0.0
        layer.cornerRadius = CGFloat(cornerRadius)
        clipsToBounds = true
        userInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init(coder aDecoder: NSCoder) {
        _inner = UIView()
        super.init(coder: aDecoder)
    }
    
    var beforeShow:(Double -> Void)?
    var beforePause:(Void -> Void)?
    
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
    
    func showInView(parent: UIView, callbackDuration:Double = 2.2, pauseDuration:Double = 1.4, fadeDuration:Double = 0.6) {
        showInView(parent) { floatingView in
            // Center
            parent.addConstraints([
                NSLayoutConstraint(item: floatingView, attribute: .CenterX, relatedBy: .Equal, toItem: parent, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: floatingView, attribute: .CenterY, relatedBy: .Equal, toItem: parent, attribute: .CenterY, multiplier: 1.0, constant: 0.0)])
            
            if let callback = self.beforeShow {
                callback(callbackDuration)
            }
            if let callback = self.beforePause {
                _ = delay(callbackDuration) {
                    callback()
                }
            }
            UIView.animateWithDuration(fadeDuration,
                delay: callbackDuration + pauseDuration,
                options: .CurveEaseInOut,
                animations: { floatingView.alpha = 0 },
                completion: { (b:Bool) in
                    floatingView.removeFromSuperview()
            })
        }
    }
}