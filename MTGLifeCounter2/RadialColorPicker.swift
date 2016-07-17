//
//  RadialColorPicker.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 15/06/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

private class ColorInfo {
    let color:MtgColor
    var rect:CGRect
    var hilight:Bool = false
    
    init(color: MtgColor, rect: CGRect) {
        self.color = color
        self.rect = rect
    }
}

private let coreColors:[MtgColor] = [.White, .Blue, .Black, .Red, .Green] // WUBRG
private let pairedColors:[MtgColor] = [.WhiteBlack,
                               .WhiteBlue,
                               .BlueRed,
                               .BlueBlack,
                               .BlackGreen,
                               .BlackRed,
                               .RedWhite,
                               .RedGreen,
                               .GreenBlue,
                               .GreenWhite]

class RadialColorPicker : UIView {
    private let _tapCallback:(RadialColorPicker, MtgColor?) -> Void
    private let _colorInfo:[ColorInfo]
    
    required init(frame: CGRect, tapCallback:((RadialColorPicker, MtgColor?) -> Void)) {
        _tapCallback = tapCallback
        assert(frame.width == frame.height)
        
        _colorInfo = (coreColors + pairedColors).map{ c in ColorInfo(color: c, rect: CGRectNull) }
        
        super.init(frame: frame)
        
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
    }
    
    private func hitTestForColor(point:CGPoint) -> ColorInfo? {
        for info in _colorInfo {
            if info.rect.contains(point) { // TODO experiment - we might need to inset the boxes
                return info
            }
        }
        return nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let hit = hitTestForColor(touch.locationInView(self))
        if let h = hit {
            h.hilight = true
            setNeedsDisplay()
        }
        
        _tapCallback(self, hit?.color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let gc = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(gc)
        defer{ CGContextRestoreGState(gc) }
        
        drawSegments(gc, frame: rect, colors: _colorInfo[4..<15], offset: rect.midX * 0.8, width: rect.midX * 0.4)
        
        drawSegments(gc, frame: rect, colors: _colorInfo[0..<5], offset: rect.midX * 0.4, width: rect.midX * 0.4)
    }
    
    private func drawSegments(context: CGContext, frame: CGRect, colors:ArraySlice<ColorInfo>, offset: CGFloat, width: CGFloat) {
        
        let num = colors.count
        for (idx, ci) in colors.enumerate() {
            let mtgColor = ci.color
            
            let startPct = Double(idx) / Double(num)
            let endPct = (Double(idx + 1) / Double(num))
            
            let start = (M_PI * 2 * startPct) - M_PI_2
            let end = (M_PI * 2 * endPct) - M_PI_2
            
            let bounds = drawSegment(context, frame: frame, offset: offset, width: width, startAngle: CGFloat(start), endAngle: CGFloat(end), colorA: mtgColor.lookup(true), colorB: mtgColor.lookup(false), hilight: ci.hilight)
            
            if ci.rect == CGRectNull { // assign if not already assigned, so someone can hit test later
                ci.rect = CGRectInset(bounds, 3, 3) // inset slightly due to non-rectangular things
            }
        }
    }
    
    private func drawSegment(context: CGContext, frame: CGRect, offset: CGFloat, width:CGFloat, startAngle: CGFloat, endAngle: CGFloat, colorA: UIColor, colorB: UIColor, hilight: Bool) -> CGRect {
        let center = frame.midX
        
        let arc = CGPathCreateMutable()
        CGPathAddArc(arc, nil, center, center, offset, startAngle, endAngle, false)
        let strokedArc = CGPathCreateCopyByStrokingPath(arc, nil, width, CGLineCap.Butt, CGLineJoin.Miter, 10)
        let boundingBox = CGPathGetBoundingBox(strokedArc)
        
        let resolvedColorA = hilight ? hilightColor(colorA) : colorA
        let resolvedColorB = hilight ? hilightColor(colorB) : colorB
        
        if(colorA == colorB) {
            // flat color, use a simpler method for efficiency
            CGContextBeginPath(context);
            CGContextAddPath(context, strokedArc)
            CGContextSetFillColorWithColor(context, resolvedColorA.CGColor)
            CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
            CGContextSetLineWidth(context, 3)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        } else {
            // gradient - linear gradient because it's simpler
            let c1 = CGColorGetComponents(resolvedColorA.CGColor)
            let c2 = CGColorGetComponents(resolvedColorB.CGColor)
            
            let locations:[CGFloat] = [0.2, 0.8]
            let components:[CGFloat] = [c1.memory, (c1+1).memory,(c1+2).memory,(c1+3).memory,
                                        c2.memory, (c2+1).memory,(c2+2).memory,(c2+3).memory ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
            
            CGContextSaveGState(context);
            CGContextAddPath(context, strokedArc);
            CGContextClip(context);
            
            let gradientStart = CGPointMake(boundingBox.minX, boundingBox.minY)
            let gradientEnd   = CGPointMake(boundingBox.maxX, boundingBox.maxY)
            
            CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, CGGradientDrawingOptions(rawValue: 0))
            CGContextRestoreGState(context)
        }
        return boundingBox
    }
    
    private func hilightColor(color: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: min(r + 0.2, 1),
                green: min(g + 0.2, 1),
                blue: min(b + 0.2, 1),
                alpha: a)
        }
        return color //nop as we failed
    }

}
