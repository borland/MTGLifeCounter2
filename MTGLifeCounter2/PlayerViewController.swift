//
//  PlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum DisplaySize {
    case small, normal
}

enum PlusMinusButtonPosition { // use nil for auto
    case rightLeft, // + on the right, - on the left
    leftRight,
    aboveBelow, // + above, - below
    belowAbove
}

enum PlayerViewOrientation {
    case normal, upsideDown, left, right
}

protocol PlayerViewControllerDelegate : AnyObject {
    func colorDidChange(newColor:MtgColor, sender:PlayerViewController)
}

class PlayerViewController : UIViewController {
    private let _tracker = LifeTotalDeltaTracker()
    
    private var _xConstraint: NSLayoutConstraint?
    private var _yConstraint: NSLayoutConstraint?
    private var _currentColorPicker:RadialColorPicker?
    
    @IBOutlet private var backgroundView: PlayerBackgroundView!
    @IBOutlet private weak var lifeTotalLabel: UILabel!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var minusButton: UIButton!
    
    // the last time layout was performed, what shape was the container (the PVC itself)
    private var _lastLayoutContainerOrientation = ContainerOrientation.landscape
    
    @IBAction private func plusButtonPressed(_ sender: AnyObject) {
        lifeTotal += 1
    }
    
    @IBAction private func minusButtonPressed(_ sender: AnyObject) {
        lifeTotal -= 1
    }
    
    @IBAction private func lifeTotalPanning(_ sender: UIPanGestureRecognizer) {
        let translation = resolve(translation: sender.translation(in: backgroundView))
        
        let verticalPanDivisor:CGFloat = 10.0
        if translation.y < -verticalPanDivisor || translation.y > verticalPanDivisor { // vertical pan greater than threshold
            lifeTotal -= Int(translation.y / verticalPanDivisor)
            sender.setTranslation(CGPoint(x: 0,y: 0), in: backgroundView) // reset the recognizer
        }
        
        let horizontalPanDivisor:CGFloat = 30.0
        if translation.x < -horizontalPanDivisor || translation.x > horizontalPanDivisor { // horz pan greater than threshold
            let newColor = color.rawValue + Int(translation.x / horizontalPanDivisor)
            if newColor < MtgColor.First().rawValue { // wrap
                color = MtgColor.Last()
            } else if newColor > MtgColor.Last().rawValue {
                color = MtgColor.First()
            } else if let x = MtgColor(rawValue: newColor) {
                color = x
            }
            sender.setTranslation(CGPoint(x: 0,y: 0), in: backgroundView) // reset the recognizer
        }
    }
    
    @IBAction private func lifeTotalWasTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: backgroundView)
        let reference = backgroundView.frame
        
        var up = true;
        switch resolveButtonPosition(for: _lastLayoutContainerOrientation) {
        case .rightLeft:
            up = location.x > (reference.size.width / 2)
        case .leftRight:
            up = location.x < (reference.size.width / 2)
        case .aboveBelow:
            up = location.y < (reference.size.height / 2)
        case .belowAbove:
            up = location.y > (reference.size.height / 2)
        }
        
        if(up) {
            plusButtonPressed(sender)
        } else {
            minusButtonPressed(sender)
        }
    }
    
    @IBAction private func viewWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        if _currentColorPicker != nil {
            return
        }
        
        let radialHostView = RadialHostView.locate(sender.view!)
        
        let topView = self.view.window! // MUST be on screen or crash means a bug
        let size = CGFloat(300)
        let half = size/2
        
        let location = sender.location(in: topView)
        let x = min(topView.frame.width - size, max(0, location.x - half))
        let y = min(topView.frame.height - size, max(20, location.y - half))
        
        let closePicker:((RadialColorPicker) -> Void) = { picker in
            self._currentColorPicker = nil
            UIView.animate(
                withDuration: 0.2,
                animations: { picker.alpha = 0.0 },
                completion: { _ in
                    picker.removeFromSuperview()
                    radialHostView?.activePicker = nil
            })
        }
        
        let picker = RadialColorPicker(frame: CGRect(x: x, y: y, width: size, height: size)) { picker, color in
            if let c = color { self.color = c }
            closePicker(picker)
        }
        _currentColorPicker = picker
        radialHostView?.activePicker = picker
        
        picker.alpha = 0.0
        topView.addSubview(picker)
        picker.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.2) { picker.alpha = 1.0 }
    }
    
    weak var delegate:PlayerViewControllerDelegate?
    
    var buttonPosition:PlusMinusButtonPosition? // nil means "figure it out"
    
    var innerHorizontalOffset = CGFloat(0) {
        didSet {
            _xConstraint?.constant = innerHorizontalOffset
        }
    }
    
    var innerVerticalOffset = CGFloat(0) {
        didSet {
            _yConstraint?.constant = innerHorizontalOffset
        }
    }
    
    var color = MtgColor.white {
        didSet {
            refreshColors()
        }
    }
    
    func refreshColors() {
        backgroundView.setBackgroundToColors(color)
        
        if(color == MtgColor.white) {
            textColor = UIColor(red: 0.2, green:0.2, blue:0.2, alpha:1.0)
        } else {
            textColor = UIColor.white
        }
        backgroundView.addLabel(color.displayName, isUpsideDown: false, textColor: textColor)
        delegate?.colorDidChange(newColor: color, sender: self)
    }
    
    var textColor:UIColor {
        get {
            if let x = lifeTotalLabel {
                return x.textColor
            }
            return UIColor.white
        }
        set(color) {
            guard let l = lifeTotalLabel, let plus = plusButton, let minus = minusButton else { return }
            
            UIView.transition(with: l, duration: 0.25, options: .transitionCrossDissolve, animations: {
                l.textColor = color
            }, completion: nil)
            
            plus.setTitleColor(color, for: UIControl.State())
            minus.setTitleColor(color, for: UIControl.State())
        }
    }
    
    var lifeTotal = 0 {
        didSet {
            _tracker.update(lifeTotal)
            
            if let x = lifeTotalLabel {
                x.text = "\(lifeTotal)"
            }
        }
    }
    
    func resetLifeTotal(_ lifeTotal:Int) {
        _tracker.reset(lifeTotal) // do this first to avoid "+0" flash on load
        self.lifeTotal = lifeTotal
    }
    
    func reset(lifeTotal:NSNumber?, color:NSNumber?) {
        if let lt = lifeTotal,
            let x = color,
            let col = MtgColor(rawValue: x.intValue)
        {
            self.resetLifeTotal(lt.intValue)
            self.color = col
        }
    }
    
    var displaySize: DisplaySize = .normal {
        didSet {
            let windowSize = UIScreen.main.bounds
            let screenSize = min(windowSize.width, windowSize.height)
            
            // scale down more on an iPad because it doesn't quite work as nicely as math would like (the 4:3 ratio messes the maths up a little)
            // we should probably do this based on the screen RATIO rather than size, but I don't care about iPhone 4S
            let divisor:CGFloat = screenSize > 450 ? 4 : 3
            let majorFontSize = screenSize / divisor
            
            let minorFontSize = min(windowSize.width, windowSize.height) / 8 // for tracker view
            
            if let lifeTotalLabel = lifeTotalLabel {
                lifeTotalLabel.font = lifeTotalLabel.font.withSize(displaySize == .normal ? majorFontSize : majorFontSize / 1.5)
                
                let pmFont = lifeTotalLabel.font.withSize(lifeTotalLabel.font.pointSize / 2.0)
                plusButton?.titleLabel?.font = pmFont
                minusButton?.titleLabel?.font = pmFont
            }
            _tracker.floatingViewFontSize = displaySize == .normal ? minorFontSize : minorFontSize / 1.5
        }
    }
    
    var orientation: PlayerViewOrientation = .normal {
        didSet {
            // we only rotate the text; all the other stuff is taken care of manually, because
            // if we rotate the background view by 90 degrees, auto-layout clips it and it looks broken
            let xform: CGAffineTransform
            
            switch orientation {
            case .upsideDown:
                xform = CGAffineTransform.identity.rotated(by: .pi)
            case .left:
                xform = CGAffineTransform.identity.rotated(by: .pi / 2)
            case .right:
                xform = CGAffineTransform.identity.rotated(by: -.pi / 2)
            case .normal:
                xform = CGAffineTransform.identity
            }
            
            lifeTotalLabel.transform = xform
            plusButton.transform = xform
            minusButton.transform = xform
            
            _tracker.orientation = orientation
            switch orientation {
            case .normal:
                _tracker.attachPosition = .topLeft(view.topAnchor, view.leftAnchor)
            case .upsideDown:
                _tracker.attachPosition = .bottomRight(view.bottomAnchor, view.rightAnchor)
            case .left:
                _tracker.attachPosition = .topRight(view.topAnchor, view.rightAnchor)
            case .right:
                _tracker.attachPosition = .bottomLeft(view.bottomAnchor, view.leftAnchor)
            }
        }
    }
    
    var isDiceRollWinner: Bool = false {
        didSet {
            if oldValue == isDiceRollWinner {
                return // pointless update
            }
            
            // if true, we show our life total in yellow, to indicate we won the dice roll, until such time as someone changes a life total or brings up the color switcher
            // note that diceRollWinner is NOT persisted so if we back out/in it's lost too, which is on purpose
            if isDiceRollWinner {
                self.textColor = UIColor.yellow
            } else {
                refreshColors() // put it back to non-yellow
            }
        }
    }
    
    override func viewDidLoad() {
        // trigger all the property change callbacks
        lifeTotal = self.lifeTotal + 0
        orientation = self.orientation == .normal ? .normal : self.orientation
        displaySize = self.displaySize == .normal ? .normal : .small
        
        let maxColorNum = UInt32(MtgColor.Last().rawValue)
        if let x = MtgColor(rawValue: Int(arc4random_uniform(maxColorNum))) {
            color = x  // likely to get overwritten by config load
        }

        _tracker.parent = backgroundView // now the tracker can use the parent
    }
    
    override func viewDidLayoutSubviews() {
        _lastLayoutContainerOrientation = view.bounds.size.orientation
        setConstraints(for: _lastLayoutContainerOrientation)
        super.viewDidLayoutSubviews()
    }
    
    func setConstraints(for containerOrientation: ContainerOrientation) {
        let constraints = backgroundView.constraints as [NSLayoutConstraint]
        backgroundView.removeAllConstraints(
            constraints.affectingView(plusButton),
            constraints.affectingView(minusButton),
            constraints.affectingView(lifeTotalLabel))
        
        let views:[String : UIView] = ["view":backgroundView!, "plus":plusButton!, "minus":minusButton!, "lifeTotal":lifeTotalLabel!]
        
        _xConstraint = lifeTotalLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor, constant: innerHorizontalOffset)
        
        _yConstraint = lifeTotalLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: innerVerticalOffset)

        backgroundView.addConstraints([_xConstraint!, _yConstraint!])
        
        let position = resolveButtonPosition(for: containerOrientation)
        switch position {
        case .rightLeft, .leftRight: // +/- on the sides
            
            let hGap:CGFloat = displaySize == .small ? 0 : 8 // in a horizontal star, pull the +/- buttons closer
            let metrics = ["hGap": hGap]
            
            let vfl = position == .rightLeft ?
                "H:[minus(56)]-(hGap)-[lifeTotal]-(hGap)-[plus(56)]" :
                "H:[plus(56)]-(hGap)-[lifeTotal]-(hGap)-[minus(56)]"
            
            backgroundView.addConstraints(vfl, views: views, metrics: metrics)
            backgroundView.addConstraints([
                plusButton.centerYAnchor.constraint(equalTo: lifeTotalLabel.centerYAnchor),
                minusButton.centerYAnchor.constraint(equalTo: lifeTotalLabel.centerYAnchor),
            ])
            
        case .aboveBelow, .belowAbove: // +/- on the top/bottom
            let vGap:CGFloat
            switch orientation {
            case .normal, .upsideDown:
                vGap = -16
            case .left, .right:
                vGap = 0 // if the text is rotated left or right we need to move the buttons
            }
            let metrics = ["vGap": vGap]
            
            let vfl = position == .aboveBelow ?
                "V:[plus(56)]-(vGap)-[lifeTotal]-(vGap)-[minus(56)]" :
                "V:[minus(56)]-(vGap)-[lifeTotal]-(vGap)-[plus(56)]"
            
            backgroundView.addConstraints(vfl, views: views, metrics: metrics)
            backgroundView.addConstraints([
                plusButton.centerXAnchor.constraint(equalTo: lifeTotalLabel.centerXAnchor),
                minusButton.centerXAnchor.constraint(equalTo: lifeTotalLabel.centerXAnchor),
                ])
        }
        
        backgroundView.setNeedsDisplay()
    }
    
    func resolve(translation tx: CGPoint) -> CGPoint {
        switch orientation {
        case .normal:
            return tx
        case .upsideDown:
            return CGPoint(x: -tx.x, y: -tx.y)
        case .left:
            return CGPoint(x: -tx.y, y: -tx.x)
        case .right:
            return CGPoint(x: tx.y, y: tx.x)
        }
    }
    
    func resolveButtonPosition(for containerOrientation: ContainerOrientation) -> PlusMinusButtonPosition {
        func resolve(position:PlusMinusButtonPosition?) -> PlusMinusButtonPosition {
            if let p = position {
                switch p {
                case .rightLeft:
                    return orientation == .upsideDown ? .leftRight : .rightLeft
                case .leftRight:
                    return orientation == .upsideDown ? .rightLeft : .leftRight
                case .aboveBelow:
                    return orientation == .upsideDown ? .belowAbove : .aboveBelow
                case .belowAbove:
                    return orientation == .upsideDown ? .aboveBelow : .belowAbove
                }
            } else { // not set, figure it out based on the view's width/height
                switch containerOrientation {
                case .landscape: // +/- on the sides because our view is wider than it is tall
                    return resolve(position: .rightLeft)
                default:
                    return resolve(position: .aboveBelow)
                }
            }
        }
        
        return resolve(position: buttonPosition)
    }
}

class PlayerBackgroundView : UIView {
    private var _color1:UIColor = UIColor.blue
    private var _color2:UIColor = UIColor.blue
    private var _lastLabel:UILabel? = nil
    
    func setBackgroundToColors(_ color:MtgColor) {
        _color1 = color.lookup(true)
        _color2 = color.lookup(false)
        
        self.setNeedsDisplay()
    }
    
    func addLabel(_ text:String, isUpsideDown:Bool, textColor:UIColor) {
        let labelHeight = CGFloat(20)
        let labelTopOffset = CGFloat(20)
        let label = UILabel(frame:
            CGRect(x: 0, y: labelTopOffset, width: frame.width, height: labelHeight))
        
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.text = text
        label.textColor = textColor
        
        if let last = _lastLabel {
            last.removeFromSuperview()
        }
        _lastLabel = label
        
        addSubview(label)
        UIView.animate(withDuration: 0.5,
            delay:0,
            options:UIView.AnimationOptions(),
            animations:{ label.alpha = 0 },
            completion:{ _ in label.removeFromSuperview() })
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // gradient - linear gradient because it's simpler
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        _color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        _color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        // draw a flat background rectangle as the gradient doesn't "keep going"
        context?.setFillColor(_color2.cgColor)
        context?.fill(rect)
        
        //Define the gradient ----------------------
        let locations:[CGFloat] = [0.0, 1.0];
        
        let components:[CGFloat] = [r1, g1, b1, a1,
                                    r2, g2, b2, a2 ]

        let colorSpace = CGColorSpaceCreateDeviceRGB();

        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: locations.count);
        
        //Define Gradient Positions ---------------
        
        //Start point
        let sz = max(frame.size.width, frame.size.height) * 1.3
        
        let startCenter = CGPoint(x: 0, y: 0)
        let startRadius = CGFloat(0)
        
        //End point
        let endCenter = startCenter // must be the same for a simple circle gradient
        let endRadius = CGFloat(sz)
        
        let options = CGGradientDrawingOptions(rawValue: 0)
        
        //Generate the Image -----------------------
        context?.drawRadialGradient(gradient!, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: options)

        context?.restoreGState();

    }
}
