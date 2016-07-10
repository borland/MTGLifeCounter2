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
    override var containers: [UIView] { return [c1, c2, c3, c4, c5] }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
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
    }
    
    override func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(c4!),
            constraints.affectingView(c5!),
            constraints.affectingView(backButton!),
            constraints.affectingView(refreshButton!),
            constraints.affectingView(d20Button!)
        )
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!, "c4":c4!, "c5":c5!]
        
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
            
            view.addAllConstraints(
                // stack two rows vertically (just align the leftmost and let the others stick to those)
                // top row gets 53%, not 50 due to space taken up by clock
                [
                    c1.topAnchor.constraintEqualToAnchor(view.topAnchor),
                    c1.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.53),
                    
                    c4.topAnchor.constraintEqualToAnchor(c1.bottomAnchor),
                    c4.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
                ],
                
                // all top row equal height and top aligned
                [c2, c3].map { $0.heightAnchor.constraintEqualToAnchor(c1.heightAnchor) },
                [c2, c3].map { $0.topAnchor.constraintEqualToAnchor(c1.topAnchor) },
                
                // second row equal height and top aligned
                [
                    c5.heightAnchor.constraintEqualToAnchor(c4.heightAnchor),
                    c5.topAnchor.constraintEqualToAnchor(c4.topAnchor),
                ],
                
                // back button
                [
                    backButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 8),
                    backButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ],
                // refresh button
                [
                    refreshButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -8),
                    refreshButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ],
                // d20 button
                [
                    d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                    d20Button.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ]
            )
        }
    }
}
