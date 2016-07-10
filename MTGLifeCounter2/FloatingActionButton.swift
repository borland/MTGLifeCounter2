//
//  FloatingActionButton.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class FloatingActionButton : UIButton {
    
    @IBInspectable var elevation: CGFloat = 2.5
    
    override func awakeFromNib() {
        backgroundColor = GlobalTintColor
        tintColor = UIColor.whiteColor()
        
        // http://stackoverflow.com/a/34984063/234
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 22)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(elevation, elevation)
        layer.shadowOpacity = 0.66
        layer.shadowPath = shadowPath.CGPath
    }
}
