//
//  DiceRollView.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 6/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class DiceRollView {
    
    class func create(num:UInt) -> FloatingView {
        let attrs:[NSObject:AnyObject] = [NSUnderlineStyleAttributeName: NSNumber(int: 0x01)] // single underline
        let attributedText = (num == 6 || num == 9) ?
            NSAttributedString(string: "\(num)", attributes: attrs) :
            NSAttributedString(string: "\(num)")
        
        return FloatingView(text:attributedText, fontSize:120)
    }
}