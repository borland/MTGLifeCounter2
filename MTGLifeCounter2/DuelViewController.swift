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
    
    @IBOutlet weak var hostView: RadialHostView!
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if(_players.count == 2) { // all loaded
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.compact, .regular): // phone in portrait
                _players.first?.orientation = .upsideDown
            default:
                _players.first?.orientation = .normal
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let p1 = _players.first else { return }
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular): // phone in portrait
            p1.orientation = .upsideDown
        default:
            p1.orientation = .normal
        }
        
        setConstraintsFor(traitCollection)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // override this for different layouts
    override func setConstraintsFor(_ traitCollection:UITraitCollection) {
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
        case (.compact, .regular): // vertical layout, top and bottom
            view.addConstraints("V:|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
            view.addConstraints([
                backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                backButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                d20Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
            
                refreshButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                refreshButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
            ])
            
        default: // horizontal, side by side
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1]|", views: views);
            view.addConstraints("V:|[c2]|", views: views);
            
            view.addConstraints([
                backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                backButton.bottomAnchor.constraint(equalTo: d20Button.topAnchor, constant: -8),
                
                d20Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                refreshButton.topAnchor.constraint(equalTo: d20Button.bottomAnchor, constant: 8),
            ])
        }
        view.layoutSubviews()
    }
}
