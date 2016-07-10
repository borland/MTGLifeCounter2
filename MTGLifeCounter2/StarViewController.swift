//
//  StarViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 10/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class StarViewController : AbstractGameViewController {
    override var initialLifeTotal:Int { return 20 }
    override var configKey:String { return "star" }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var c4: UIView!
    @IBOutlet weak var c5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for p in _players {
            p.displaySize = .Small
        }
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addConstraints([
            backButton.widthAnchor.constraintEqualToConstant(44),
            backButton.heightAnchor.constraintEqualToAnchor(backButton.widthAnchor) ])
        
        backButton.backgroundColor = GlobalTintColor
        
        // http://stackoverflow.com/a/34984063/234
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = 22
        let shadowPath = UIBezierPath(roundedRect: backButton.bounds, cornerRadius: 22)
        backButton.layer.masksToBounds = false
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOffset = CGSizeMake(3, 3)
        backButton.layer.shadowOpacity = 0.75
        backButton.layer.shadowPath = shadowPath.CGPath
    }
    
    override func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(c4!),
            constraints.affectingView(c5!),
            constraints.affectingView(backButton!))
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!, "c4":c4!, "c5":c5!]
        
//        view.addConstraints("|[toolbar]|", views: views)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
//            view.addConstraints("V:|[c1(==c2)][c2(==c3)][c3(==c1)][toolbar(34)]|", views: views)
//            view.addConstraints("|[c1]|", views: views)
//            view.addConstraints("|[c2]|", views: views)
//            view.addConstraints("|[c3]|", views: views)
            break
            
        default:
            for p in _players {
                p.buttonOrientation = .Horizontal // force buttons on the side even though we don't normally do this in landscape
            }
            if _players.count == 5 {
                _players[3].innerHorizontalOffset = 25
                _players[4].innerHorizontalOffset = -25
            }
            
            // first row horizontally
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            
            // second row horizontally
            view.addConstraints("|[c4(==c5)][c5(==c4)]|", views: views)
            
            // two rows vertically (just align the leftmost and let the others stick to those)
            view.addConstraints("V:|[c1][c4]|", views: views)
            
            view.addAllConstraints(
                // all equal height
                [c2, c3, c4, c5].map { c1.heightAnchor.constraintEqualToAnchor($0.heightAnchor) },
                
                // align tops of two rows
                [c2, c3].map { c1.topAnchor.constraintEqualToAnchor($0.topAnchor) },
                [ c5.topAnchor.constraintEqualToAnchor(c4.topAnchor) ],
                
                // back button
                [
                    backButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 8),
                    backButton.topAnchor.constraintLessThanOrEqualToAnchor(c4.topAnchor, constant: 8)
                ]
            )
        }
    }
}
