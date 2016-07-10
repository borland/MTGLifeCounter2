//
//  DuelViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class DuelViewController : AbstractGameViewController {
    override var initialLifeTotal:Int { return 20 }
    override var configKey:String { return "duel" }
    override var containers:[UIView] { return [c1, c2] }
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    // specialized because of upside down
    override func d20ButtonPressed(sender: AnyObject) {
        for (c, (num, winner)) in zip(containers, randomUntiedDiceRolls(containers.count, diceFaceCount: UInt(20))) {
            let diceRollView = DiceRollView.create(num, winner:winner)
            
            if c == c1 {
                switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
                case (.Compact, .Regular): // phone in portrait
                    diceRollView.isUpsideDown = true
                default:
                    diceRollView.isUpsideDown = false
                }
            }
            
            diceRollView.showInView(c)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if(_players.count == 2) { // all loaded
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.Compact, .Regular): // phone in portrait
                _players.first?.isUpsideDown = true
            default:
                _players.first?.isUpsideDown = false
            }
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let p1 = _players.first else { return }
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            p1.isUpsideDown = true
        default:
            p1.isUpsideDown = false
        }
        
        setConstraintsFor(traitCollection)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // override this for different layouts
    override func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(backButton!),
            constraints.affectingView(d20Button!),
            constraints.affectingView(refreshButton!)
        )
        
        let views = ["c1":c1!, "c2":c2!]
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular):
            view.addConstraints("V:|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
            view.addAllConstraints(
                [
                    backButton.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 8),
                    backButton.centerXAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ],
                [
                    refreshButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -8),
                    refreshButton.centerXAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ],
                [
                    d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                    d20Button.centerYAnchor.constraintEqualToAnchor(c1.bottomAnchor)
                ]
            )
            
        default:
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1]|", views: views);
            view.addConstraints("V:|[c2]|", views: views);
            
            view.addConstraints([
                backButton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 8),
                backButton.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
                
                refreshButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -8),
                refreshButton.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
                
                d20Button.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
                d20Button.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
            ])
        }
        view.layoutSubviews()
    }
}