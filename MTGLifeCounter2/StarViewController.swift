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
        assert(_players.count == 5) // called before view loaded?
        
        for p in _players {
            p.buttonPosition = .Sides // force buttons on the side even though we don't normally do this in landscape
            p.innerHorizontalOffset = 0
        }
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            _players[0].orientation = .UpsideDown
//            _players[1].orientation = .Left
//            _players[2].orientation = .Right
//            _players[3].orientation = .Left
//            _players[4].orientation = .Right
            // I want to rotate, but it breaks; fix in progress
            _players[1].orientation = .Normal
            _players[2].orientation = .Normal
            _players[3].orientation = .Normal
            _players[4].orientation = .Normal
            
            view.addConstraints([
                // c1 fills horizontal
                c1.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
                c1.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
                
                // c2, c3
                c2.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
                c3.leadingAnchor.constraintEqualToAnchor(c2.trailingAnchor),
                c3.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
                
                c3.widthAnchor.constraintEqualToAnchor(c2.widthAnchor),
                c3.heightAnchor.constraintEqualToAnchor(c2.heightAnchor),
                c3.topAnchor.constraintEqualToAnchor(c2.topAnchor),
                
                // c4, c5
                c4.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
                c5.leadingAnchor.constraintEqualToAnchor(c4.trailingAnchor),
                c5.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
                
                c5.widthAnchor.constraintEqualToAnchor(c4.widthAnchor),
                c5.heightAnchor.constraintEqualToAnchor(c4.heightAnchor),
                c5.topAnchor.constraintEqualToAnchor(c4.topAnchor),
                
                // stack the left row all vertically
                c1.topAnchor.constraintEqualToAnchor(view.topAnchor),
                c2.topAnchor.constraintEqualToAnchor(c1.bottomAnchor),
                c4.topAnchor.constraintEqualToAnchor(c2.bottomAnchor),
                c4.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
                
                // top view gets less space (not 33%) because it's wider, other views split evenly
                c1.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.30),
                // c2,3 get a bit more space as they're overlapped by buttons
                c2.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.37),
                
                // buttons
                backButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 8),
                backButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor),
                
                d20Button.centerXAnchor.constraintEqualToAnchor(c1.centerXAnchor),
                d20Button.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor),
                
                refreshButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -8),
                refreshButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
            ])
            break
            
        default: // landscape view
            _players[0].orientation = .UpsideDown
            _players[1].orientation = .UpsideDown
            _players[2].orientation = .UpsideDown
            _players[3].orientation = .Normal
            _players[4].orientation = .Normal
            
            _players[3].innerHorizontalOffset = 25
            _players[4].innerHorizontalOffset = -25
            
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

                // back button
                backButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 8),
                backButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor),

                // refresh button
                refreshButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -8),
                refreshButton.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor),

                // d20 button
                d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                d20Button.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ]
            )
        }
    }
}
