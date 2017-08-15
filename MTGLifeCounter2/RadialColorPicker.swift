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

private let coreColors:[MtgColor] = [.white, .blue, .black, .red, .green] // WUBRG
private let pairedColors:[MtgColor] = [.whiteBlack,
                               .whiteBlue,
                               .blueRed,
                               .blueBlack,
                               .blackGreen,
                               .blackRed,
                               .redWhite,
                               .redGreen,
                               .greenBlue,
                               .greenWhite]

class RadialHostView : UIView {
    static func locate(_ view: UIView) -> RadialHostView? {
        var v : UIView = view
        repeat {
            if let r = v as? RadialHostView {
                return r
            }
            guard let sv = v.superview else {
                return nil
            }
            v = sv
        } while true
    }
    
    var activePicker : RadialColorPicker?
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
////        if let _ = activePicker {
//            print("touches moved")
////        }
//        return super.hitTest(point, withEvent: event)
//    }
}

//class TouchesMovedRecognizer : UIGestureRecognizer {
//    func touchesMoved(touches:NSSet, withEvent event:UIEvent) {
//        self.state = .Recognized
//    }
//}

class RadialColorPicker : UIView {
    private let _tapCallback:(RadialColorPicker, MtgColor?) -> Void
    private let _colorInfo:[ColorInfo]
    
    required init(frame: CGRect, tapCallback: @escaping ((RadialColorPicker, MtgColor?) -> Void)) {
        _tapCallback = tapCallback
        assert(frame.width == frame.height)
        
        _colorInfo = (coreColors + pairedColors).map{ c in ColorInfo(color: c, rect: CGRect.null) }
        
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let radius = frame.width
        layer.cornerRadius = radius / 2
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.66
        layer.shadowPath = shadowPath.cgPath
        
        isMultipleTouchEnabled = true
    }
    
    private func hitTestForColor(_ point:CGPoint) -> ColorInfo? {
        for info in _colorInfo {
            if info.rect.contains(point) { // TODO experiment - we might need to inset the boxes
                return info
            }
        }
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let hit = hitTestForColor(touch.location(in: self))
        if let h = hit {
            h.hilight = true
            setNeedsDisplay()
        }
        
        _tapCallback(self, hit?.color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let gc = UIGraphicsGetCurrentContext()!
        gc.saveGState()
        defer{ gc.restoreGState() }
        
        drawSegments(gc, frame: rect, colors: _colorInfo[5..<15], offset: rect.midX * 0.8, width: rect.midX * 0.4)
        
        drawSegments(gc, frame: rect, colors: _colorInfo[0..<5], offset: rect.midX * 0.4, width: rect.midX * 0.4)
    }
    
    private func drawSegments(_ context: CGContext, frame: CGRect, colors:ArraySlice<ColorInfo>, offset: CGFloat, width: CGFloat) {
        
        let num = colors.count
        for (idx, ci) in colors.enumerated() {
            let mtgColor = ci.color
            
            let startPct = Double(idx) / Double(num)
            let endPct = (Double(idx + 1) / Double(num))
            
            let start = (Double.pi * 2.0 * startPct) - Double.pi / 2
            let end = (Double.pi * 2.0 * endPct) - Double.pi / 2
            
            let bounds = drawSegment(context, frame: frame, offset: offset, width: width, startAngle: CGFloat(start), endAngle: CGFloat(end), color1: mtgColor.lookup(true), color2: mtgColor.lookup(false), hilight: ci.hilight)
            
            if ci.rect == CGRect.null { // assign if not already assigned, so someone can hit test later
                ci.rect = bounds.insetBy(dx: 3, dy: 3) // inset slightly due to non-rectangular things
            }
        }
    }
    
    private func drawSegment(_ context: CGContext, frame: CGRect, offset: CGFloat, width:CGFloat, startAngle: CGFloat, endAngle: CGFloat, color1: UIColor, color2: UIColor, hilight: Bool) -> CGRect {
        let center = CGPoint(x: frame.midX, y: frame.midX)
        
        let arc = CGMutablePath()
        arc.addArc(center: center, radius: offset, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        let strokedArc = CGPath(__byStroking: arc, transform: nil, lineWidth: width, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: 10)
        let boundingBox = strokedArc?.boundingBox
        
        let resolvedColor1 = hilight ? hilightColor(color1) : color1
        let resolvedColor2 = hilight ? hilightColor(color2) : color2
        
        if(color1 == color2) {
            // flat color, use a simpler method for efficiency
            context.beginPath();
            context.addPath(strokedArc!)
            context.setFillColor(resolvedColor1.cgColor)
            context.setStrokeColor(UIColor.gray.cgColor)
            context.setLineWidth(3)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        } else {
            // gradient - linear gradient because it's simpler
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
            
            resolvedColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            resolvedColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
            
            let locations:[CGFloat] = [0.2, 0.8]
            let components:[CGFloat] = [r1, g1, b1, a1,
                                        r2, g2, b2, a2 ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
            
            context.saveGState();
            context.addPath(strokedArc!);
            context.clip();
            
            let gradientStart = CGPoint(x: (boundingBox?.minX)!, y: (boundingBox?.minY)!)
            let gradientEnd   = CGPoint(x: (boundingBox?.maxX)!, y: (boundingBox?.maxY)!)
            
            context.drawLinearGradient(gradient!, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions(rawValue: 0))
            context.restoreGState()
        }
        return boundingBox!
    }
    
    private func hilightColor(_ color: UIColor) -> UIColor {
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
