//
//  RadialColorPicker.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 15/06/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class RadialColorPicker : UIView {
    required init(radius: CGFloat) {
        super.init(frame: CGRectMake(0, 0, radius, radius))
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: radius),
            NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: radius),
            ])
        
        layer.cornerRadius = radius / 2
        clipsToBounds = true
        backgroundColor = UIColor.grayColor()
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let gc = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(gc)
        defer{ CGContextRestoreGState(gc) }
        
        let coreColors:[MtgColor] = [.White, .Blue, .Black, .Red, .Green]
        let paired:[MtgColor] = [.WhiteBlue,. BlueBlack, .BlackRed, .RedGreen, .GreenWhite, .WhiteBlack, .BlueRed, .BlackGreen, .RedWhite, .GreenBlue]
        
        gc.drawSegments(rect, colors: paired, offset: rect.midX * 0.8, width: rect.midX * 0.4)
        gc.drawSegments(rect, colors: coreColors, offset: rect.midX * 0.4, width: rect.midX * 0.4)
    }
}

private extension CGContext {
    func drawSegments(rect: CGRect, colors:[MtgColor], offset: CGFloat, width: CGFloat) {
        let num = colors.count
        for i in 0..<num {
            let startPct = Double(i) / Double(num)
            let endPct = (Double(i + 1) / Double(num))
            
            let start = (M_PI * 2 * startPct) - M_PI_2
            let end = (M_PI * 2 * endPct) - M_PI_2
            let col = colors[i].lookup(true)
            
            drawSegment(rect, offset: offset, width: width, startAngle: CGFloat(start), endAngle: CGFloat(end), color: col)
        }
    }
    
    func drawSegment(rect: CGRect, offset: CGFloat, width:CGFloat, startAngle: CGFloat, endAngle: CGFloat, color:UIColor) {
        let center = rect.midX
        
        CGContextBeginPath(self);
        CGContextAddArc(self, center, center, offset, startAngle, endAngle, 0)
        CGContextSetLineWidth(self, width)
        CGContextSetStrokeColorWithColor(self, color.CGColor)
        CGContextStrokePath(self)
    }
}