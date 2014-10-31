//
//  Utility.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addConstraints(format:String, views:[String:UIView], options:NSLayoutFormatOptions=NSLayoutFormatOptions(0)) {
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(
            format,
            options: options,
            metrics: nil,
            views: views)
        
        self.addConstraints(constraints)
    }
}
