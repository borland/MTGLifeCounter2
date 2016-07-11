//
//  ThreePlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 8/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class ThreePlayerViewController : AbstractGameViewController {
    override var initialLifeTotal: Int { return 20 }
    override var configKey:String { return "threePlayer" }
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(backButton!),
            constraints.affectingView(d20Button!),
            constraints.affectingView(refreshButton!))
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!]
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            _players[0].innerVerticalOffset = 0
            _players[1].innerVerticalOffset = 0
            _players[2].innerVerticalOffset = -20
            
            view.addAllConstraints(
                // views all fill horizontal space
                [c1, c2, c3].map { $0.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor) },
                [c1, c2, c3].map { $0.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor) },
                
                [
                    // stack them all vertically
                    c1.topAnchor.constraintEqualToAnchor(view.topAnchor),
                    c2.topAnchor.constraintEqualToAnchor(c1.bottomAnchor),
                    c3.topAnchor.constraintEqualToAnchor(c2.bottomAnchor),
                    c3.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
                    
                    // bottom view gets more space (not 33%) to allow for buttons, other views split evenly
                    c3.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.37),
                    c1.heightAnchor.constraintEqualToAnchor(c2.heightAnchor),
                    
                    // buttons
                    backButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 8),
                    backButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                    
                    d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                    d20Button.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                    
                    refreshButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -8),
                    refreshButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8)
                ])
            
        default:
            _players[0].innerVerticalOffset = -10
            _players[1].innerVerticalOffset = -10
            _players[2].innerVerticalOffset = -10
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            view.addConstraints("V:|[c1]|", views: views)
            view.addConstraints("V:|[c2]|", views: views)
            view.addConstraints("V:|[c3]|", views: views)
            
            view.addConstraints([
                backButton.centerXAnchor.constraintEqualToAnchor(c2.leftAnchor),
                backButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                
                d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                d20Button.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                
                refreshButton.centerXAnchor.constraintEqualToAnchor(c2.rightAnchor),
                refreshButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                ])
        }
    }
}