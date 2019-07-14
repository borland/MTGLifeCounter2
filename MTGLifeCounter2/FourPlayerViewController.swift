//
//  FourPlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 14/07/19.
//  Copyright © 2019 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class FourPlayerViewController : AbstractGameViewController {
    override var initialLifeTotal: Int { return 20 }
    override var configKey:String { return "fourPlayer" }
    
    // these get added to _players in the base class by the ViewController containment segue
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var c4: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func playerColorDidChange(deviceOrientation: ContainerOrientation) {
        if(_players.count != 4) { return } // gets called spuriously during load
        
        // clock only shows in portrait
        switch (deviceOrientation, _players[0].color, _players[1].color) {
        case (.portrait, .white, _),
            (.portrait, _, .white): // if either p1 or p2 is white then the clock is black
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
            constraints.affectingView(c4!),
            constraints.affectingView(backButton!),
            constraints.affectingView(d20Button!),
            constraints.affectingView(refreshButton!))
        
        let safeArea = view.safeAreaLayoutGuide
        
        // LAYOUT is identical in both portrait or landscape
        // [ c1  c2 ]
        // [<   D  r]
        // [ c3  c4 ]
        _players[0].orientation = .upsideDown
        _players[1].orientation = .upsideDown
        _players[2].orientation = .normal
        _players[3].orientation = .normal
        
        view.addAllConstraints(
            // horizontal, attach c1, c3 to left edge
            [c1, c3].map { $0.leadingAnchor.constraint(equalTo: view.leadingAnchor) },
            // horizontal, attach c2, c4 to right edge
            [c2, c4].map { $0.trailingAnchor.constraint(equalTo: view.trailingAnchor) },
            
            // vertical, attach c1, c2 to top edge
            [c1, c2].map { $0.topAnchor.constraint(equalTo: view.topAnchor) },
            // vertical, attach c3, c4 to bottom edge
            [c3, c4].map { $0.bottomAnchor.constraint(equalTo: view.bottomAnchor) },
            
            [
                // attach to eachother vertically
                c1.bottomAnchor.constraint(equalTo: c3.topAnchor),
                c1.heightAnchor.constraint(equalTo: c3.heightAnchor),
                
                c2.bottomAnchor.constraint(equalTo: c4.topAnchor),
                c2.heightAnchor.constraint(equalTo: c4.heightAnchor),
                
                // attach to eachother horizontally
                c1.trailingAnchor.constraint(equalTo: c2.leadingAnchor),
                c1.widthAnchor.constraint(equalTo: c2.widthAnchor),
                
                c3.trailingAnchor.constraint(equalTo: c4.leadingAnchor),
                c3.widthAnchor.constraint(equalTo: c4.widthAnchor),
                
                ],
            
            // buttons
            [
                backButton.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 8),
                backButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                d20Button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                refreshButton.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -8),
                refreshButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
        ])
        
        switch size.orientation {
        case .portrait:
            _players[0].innerVerticalOffset = 0
            _players[1].innerVerticalOffset = 0
            // bump the controls down a bit to account for the center buttons
            _players[2].innerVerticalOffset = 10
            _players[3].innerVerticalOffset = 10
            
        case .landscape:
            _players[0].innerVerticalOffset = 0
            _players[1].innerVerticalOffset = 0
            // bump the controls down a bit to account for the center buttons
            _players[2].innerVerticalOffset = 0
            _players[3].innerVerticalOffset = 0
        }
    }
}
