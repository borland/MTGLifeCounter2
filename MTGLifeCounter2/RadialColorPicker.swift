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
    private let _tapCallback:(RadialColorPicker, MtgColor?) -> Void
    private var _boxes:[MtgColor:CGRect] = [:]
    
    required init(frame: CGRect, tapCallback:((RadialColorPicker, MtgColor?) -> Void)) {
        _tapCallback = tapCallback
        assert(frame.width == frame.height)
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let radius = frame.width

        layer.cornerRadius = radius / 2
        clipsToBounds = true
        backgroundColor = UIColor.grayColor()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped(_:))))
    }
    
    func wasTapped(sender: UITapGestureRecognizer) {
        _tapCallback(self, hitTestForColor(sender.locationInView(self)))
    }
    
    private func hitTestForColor(point:CGPoint) -> MtgColor? {
        for (color, rect) in _boxes {
            if rect.contains(point) { // TODO experiment - we might need to inset the boxes
                return color
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let gc = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(gc)
        defer{ CGContextRestoreGState(gc) }
        
        let coreColors:[MtgColor] = [.White, .Blue, .Black, .Red, .Green] // WUBRG
        let paired:[MtgColor] = [.WhiteBlack,
            .WhiteBlue,
            .BlueRed,
            .BlueBlack,
            .BlackGreen,
            .BlackRed,
            .RedWhite,
            .RedGreen,
            .GreenBlue,
            .GreenWhite]
        
        let innerBoxes = gc.drawSegments(rect, colors: paired, offset: rect.midX * 0.8, width: rect.midX * 0.4)
        let outerBoxes = gc.drawSegments(rect, colors: coreColors, offset: rect.midX * 0.4, width: rect.midX * 0.4)
        
        if _boxes.isEmpty {
            _boxes = innerBoxes
            for (k,v) in outerBoxes {
                _boxes[k] = CGRectInset(v, 3, 3) // because they're non rectangular, pull them in a bit
            }
        }
    }
}

private extension CGContext {
    func drawSegments(rect: CGRect, colors:[MtgColor], offset: CGFloat, width: CGFloat) -> [MtgColor:CGRect] {
        var boxes:[MtgColor:CGRect] = [:]
        
        let num = colors.count
        for i in 0..<num {
            let mtgColor = colors[i]
            
            let startPct = Double(i) / Double(num)
            let endPct = (Double(i + 1) / Double(num))
            
            let start = (M_PI * 2 * startPct) - M_PI_2
            let end = (M_PI * 2 * endPct) - M_PI_2
            
            boxes[mtgColor] = drawSegment(rect, offset: offset, width: width, startAngle: CGFloat(start), endAngle: CGFloat(end), colorA: mtgColor.lookup(true), colorB: mtgColor.lookup(false))
        }
        return boxes
    }
    
    func drawSegment(rect: CGRect, offset: CGFloat, width:CGFloat, startAngle: CGFloat, endAngle: CGFloat, colorA:UIColor, colorB:UIColor) -> CGRect {
        let center = rect.midX
        
        let arc = CGPathCreateMutable()
        CGPathAddArc(arc, nil, center, center, offset, startAngle, endAngle, false)
        let strokedArc = CGPathCreateCopyByStrokingPath(arc, nil, width, CGLineCap.Butt, CGLineJoin.Miter, 10)
        let boundingBox = CGPathGetBoundingBox(strokedArc)
        
        if(colorA == colorB) {
            // flat color, use a simpler method for efficiency
            CGContextBeginPath(self);
            CGContextAddPath(self, strokedArc)
            CGContextSetFillColorWithColor(self, colorA.CGColor)
            CGContextSetStrokeColorWithColor(self, UIColor.grayColor().CGColor)
            CGContextSetLineWidth(self, 3)
            CGContextDrawPath(self, CGPathDrawingMode.FillStroke)
        } else {
            // gradient - linear gradient because it's simpler
            let c1 = CGColorGetComponents(colorA.CGColor)
            let c2 = CGColorGetComponents(colorB.CGColor)
            
            let locations:[CGFloat] = [0.2, 0.8]
            let components:[CGFloat] = [c1.memory, (c1+1).memory,(c1+2).memory,(c1+3).memory,
                                        c2.memory, (c2+1).memory,(c2+2).memory,(c2+3).memory ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
            
            CGContextSaveGState(self);
            CGContextAddPath(self, strokedArc);
            CGContextClip(self);
            
            let gradientStart = CGPointMake(boundingBox.minX, boundingBox.minY)
            let gradientEnd   = CGPointMake(boundingBox.maxX, boundingBox.maxY)
            
            CGContextDrawLinearGradient(self, gradient, gradientStart, gradientEnd, CGGradientDrawingOptions(rawValue: 0))
            CGContextRestoreGState(self)
            
            // borders
            CGContextAddPath(self, strokedArc)
            CGContextSetStrokeColorWithColor(self, UIColor.grayColor().CGColor)
            CGContextSetLineWidth(self, 2)
            CGContextDrawPath(self, CGPathDrawingMode.Stroke)
        }
        return boundingBox
    }
}