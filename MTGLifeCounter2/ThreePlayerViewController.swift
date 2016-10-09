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
    
    override func playerColorDidChange(deviceOrientation: ContainerOrientation) {
        if(_players.count != 3) { return } // gets called spuriously during load
        
        switch (deviceOrientation,
                _players[0].color, _players[1].color, _players[2].color) {
        case (.portrait, .white, _, _), // portrait, top VC is white
            (.landscape, _, .white, _): // landscape, middle white
            statusBarStyle = .default
        default:
            statusBarStyle = .lightContent
        }
    }
    
    override func setConstraints(for size: CGSize) {
        let constraints = view.constraints
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(backButton!),
            constraints.affectingView(d20Button!),
            constraints.affectingView(refreshButton!))
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!]
        
        switch size.orientation {
        case .portrait: // phone in portrait
            _players[0].innerVerticalOffset = 0
            _players[1].innerVerticalOffset = 0
            _players[2].innerVerticalOffset = -20
            
            view.addAllConstraints(
                // views all fill horizontal space
                [c1, c2, c3].map { $0.leadingAnchor.constraint(equalTo: view.leadingAnchor) },
                [c1, c2, c3].map { $0.trailingAnchor.constraint(equalTo: view.trailingAnchor) },
                
                [
                    // stack them all vertically
                    c1.topAnchor.constraint(equalTo: view.topAnchor),
                    c2.topAnchor.constraint(equalTo: c1.bottomAnchor),
                    c3.topAnchor.constraint(equalTo: c2.bottomAnchor),
                    c3.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    
                    // bottom view gets more space (not 33%) to allow for buttons, other views split evenly
                    c3.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.37),
                    c1.heightAnchor.constraint(equalTo: c2.heightAnchor),
                    
                    // buttons
                    backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                    backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
                    
                    d20Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    d20Button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
                    
                    refreshButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                    refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
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
                backButton.centerXAnchor.constraint(equalTo: c2.leftAnchor),
                backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
                
                d20Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                d20Button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
                
                refreshButton.centerXAnchor.constraint(equalTo: c2.rightAnchor),
                refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
                ])
        }
    }
}
