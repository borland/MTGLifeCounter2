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
            return [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        }
    }
}

class DiceRollView {
    
    class func create(_ num:UInt, winner:Bool, orientation: PlayerViewOrientation) -> FloatingView {
        let singleUnderline:[NSAttributedStringKey:Any] = [NSAttributedStringKey.underlineStyle: 1]
        
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
        
        let numberView = NumberWheelView(fontSize: 110, textColor: UIColor.white, numCells:30, generator: generator)
        let widthConstraint = NSLayoutConstraint(item: numberView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 135)
        let heightConstraint = NSLayoutConstraint(item: numberView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 125)

        numberView.addConstraints([widthConstraint, heightConstraint])

        let fv = FloatingView(innerView: numberView, cornerRadius: 120 / 5)
        fv.beforeShow = { numberView.spinWithDuration($0 - 0.25) }
        fv.beforePause = {
            if winner {
                // gold
                fv.backgroundColor = UIColor(red:0.988, green:0.761, blue:0, alpha:1.0)
                let duration = 0.1
                let initialTransform = fv.transform

                UIView.animate(withDuration: duration, delay: 0, options: .autoreverse,
                    animations: {
                        fv.transform = initialTransform.concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
                    }, completion: { _ in
                        fv.transform = initialTransform
                        // this is how we "repeat" one time
                        UIView.animate(withDuration: duration, delay: 0, options: .autoreverse,
                            animations: {
                                fv.transform = initialTransform.concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
                            }, completion: { _ in
                                fv.transform = initialTransform
                        })

                })
            }
        } as (() -> Void)
        
        switch orientation {
        case .upsideDown:
            fv.transform = CGAffineTransform.identity.rotated(by: .pi)
        case .left:
            fv.transform = CGAffineTransform.identity.rotated(by: .pi / 2)
        case .right:
            fv.transform = CGAffineTransform.identity.rotated(by: -.pi / 2)
        case .normal:
            fv.transform = CGAffineTransform.identity
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
        label.textColor = UIColor.white
        label.attributedText = text
        label.font = UIFont(name:"Futura", size:fontSize)
        label.textAlignment = .center
        label.sizeToFit()
        
        self.init(innerView:label)
    }
    
    // will wrap innerView in a rounded-rect border with 10px padding and center it in the frame
    // the overall size will be determined by innerView's intrinsic size
    required init(innerView:UIView, cornerRadius:Float = 20) {
        _inner = innerView
        
        super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
    
        backgroundColor = UIColor.blue
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerView)
        addConstraints("H:|-[inner]-|", views: ["inner":innerView], options: .alignAllLastBaseline)
        addConstraints("V:|-[inner]-|", views: ["inner":innerView], options: .alignAllLastBaseline)
        sizeToFit()

        backgroundColor = UIColor(red:0.3, green:0.1, blue:0.7, alpha:1)
        alpha = 0.0
        layer.cornerRadius = CGFloat(cornerRadius)
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    // not needed but compiler makes us add it
    required init?(coder aDecoder: NSCoder) {
        _inner = UIView()
        super.init(coder: aDecoder)
    }
    
    var beforeShow:((Double) -> Void)?
    var beforePause:(() -> Void)?
    
    var isUpsideDown:Bool {
        get{ return _isUpsideDown }
        set(value) {
            _isUpsideDown = value
            propertyDidChange("isUpsideDown")
        }
    }
    
    func propertyDidChange(_ propertyName:String) {
        switch(propertyName) {
        case "isUpsideDown":
            if _isUpsideDown {
                transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
            } else {
                transform = CGAffineTransform.identity;
            }
            
        default:
            assertionFailure("unhandled property")
        }
    }
    
    func showInView(_ parent: UIView, setup: (UIView) -> ()) {
        alpha = 1.0
        
        parent.addSubview(self)
        
        setup(self)
    }
    
    func showInView(_ parent: UIView, callbackDuration:Double = 2.2, pauseDuration:Double = 1.4, fadeDuration:Double = 0.6) {
        showInView(parent) { floatingView in
            // Center
            parent.addConstraints([
                NSLayoutConstraint(item: floatingView, attribute: .centerX, relatedBy: .equal, toItem: parent, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: floatingView, attribute: .centerY, relatedBy: .equal, toItem: parent, attribute: .centerY, multiplier: 1.0, constant: 0.0)])
            
            if let callback = self.beforeShow {
                callback(callbackDuration)
            }
            if let callback = self.beforePause {
                _ = delay(callbackDuration) {
                    callback()
                }
            }
            UIView.animate(withDuration: fadeDuration,
                delay: callbackDuration + pauseDuration,
                options: UIViewAnimationOptions(),
                animations: { floatingView.alpha = 0 },
                completion: { (b:Bool) in
                    floatingView.removeFromSuperview()
            })
        }
    }
}
