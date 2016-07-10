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
    private var _hitTestRects:[MtgColor:CGRect] = [:]
    
    private var _drawPercentage = 0.0 // between 0 and 1
    private let _drawPercentageEachTick = 0.1 // 10 ticks, then we stop
    private var _drawTimer:NSTimer?
    
    required init(frame: CGRect, tapCallback:((RadialColorPicker, MtgColor?) -> Void)) {
        _tapCallback = tapCallback
        assert(frame.width == frame.height)
        super.init(frame: frame)
        
        _drawTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(timerDidFire(_:)), userInfo: nil, repeats: true)
        _drawTimer!.tolerance = 0 // no concern for battery on an animation that only lasts 100ms
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let radius = frame.width
        layer.cornerRadius = radius / 2
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowOpacity = 0.66
        layer.shadowPath = shadowPath.CGPath
        
        multipleTouchEnabled = true
        
//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped(_:))))
    }
    
    func timerDidFire(timer:NSTimer) {
        _drawPercentage += _drawPercentageEachTick
        setNeedsDisplay()
        if let timer = _drawTimer where _drawPercentage >= 1 {
            timer.invalidate()
            _drawTimer = nil
        }
    }
    
    private func hitTestForColor(point:CGPoint) -> MtgColor? {
        for (color, rect) in _hitTestRects {
            if rect.contains(point) { // TODO experiment - we might need to inset the boxes
                return color
            }
        }
        return nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        _tapCallback(self, hitTestForColor(touch.locationInView(self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let gc = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(gc)
        defer{ CGContextRestoreGState(gc) }
        
        let coreColors:[MtgColor] = [.White, .Blue, .Black, .Red, .Green] // WUBRG
        let pairedColors:[MtgColor] = [.WhiteBlack,
            .WhiteBlue,
            .BlueRed,
            .BlueBlack,
            .BlackGreen,
            .BlackRed,
            .RedWhite,
            .RedGreen,
            .GreenBlue,
            .GreenWhite]
        
        let thresholdPaired = 1.0 / Double(pairedColors.count)
        let howManyPaired = Int(_drawPercentage / thresholdPaired)
        let pairedRects = gc.drawSegments(rect, colors: pairedColors, howMany:  howManyPaired, offset: rect.midX * 0.8, width: rect.midX * 0.4)
        
        let thresholdCore = 1.0 / Double(coreColors.count)
        let howManyCore = Int(_drawPercentage / thresholdCore)
        let coreRects = gc.drawSegments(rect, colors: coreColors, howMany:howManyCore, offset: rect.midX * 0.4, width: rect.midX * 0.4)
        
        if _drawPercentage >= 1.0 && _hitTestRects.isEmpty {
            backgroundColor = UIColor.grayColor()
            
            _hitTestRects = pairedRects
            for (k,v) in coreRects {
                _hitTestRects[k] = CGRectInset(v, 3, 3) // because they're non rectangular, pull them in a bit
            }
        }
    }
}

private extension CGContext {
    func drawSegments(rect: CGRect, colors:[MtgColor], howMany:Int, offset: CGFloat, width: CGFloat) -> [MtgColor:CGRect] {
        var boxes:[MtgColor:CGRect] = [:]
        
        let num = colors.count
        for i in 0..<howMany {
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
//            CGContextAddPath(self, strokedArc)
//            CGContextSetStrokeColorWithColor(self, UIColor.grayColor().CGColor)
//            CGContextSetLineWidth(self, 2)
//            CGContextDrawPath(self, CGPathDrawingMode.Stroke)
        }
        return boundingBox
    }
}