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
            switch view.bounds.size.orientation {
            case (.portrait):
                _players.first?.orientation = .upsideDown
            default:
                _players.first?.orientation = .normal
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let p1 = _players.first else { return }
        
        switch size.orientation {
        case .portrait:
            p1.orientation = .upsideDown
        default:
            p1.orientation = .normal
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func playerColorDidChange(deviceOrientation: ContainerOrientation) {
        if(_players.count != 2) { return } // gets called spuriously during load
        
        switch (deviceOrientation, _players[0].color, _players[1].color) {
        case (.portrait, .white, _), // portrait, top VC is white
            (.landscape, .white, .white): // landscape, both white
            statusBarStyle = .default
        default:
            statusBarStyle = .lightContent // everything else SB goes white
        }
    }
    
    // override this for different layouts
    override func setConstraints(for size: CGSize) {
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(backButton!),
            constraints.affectingView(d20Button!),
            constraints.affectingView(refreshButton!)
        )
        
        let views = ["c1":c1!, "c2":c2!]
        
        let safeArea = view.safeAreaLayoutGuide
        
        if size.orientation == .portrait {
            view.addConstraints("V:|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
            view.addConstraints([
                backButton.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 8),
                backButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                d20Button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
            
                refreshButton.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -8),
                refreshButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
            ])
        }
        else {
            assert(size.orientation == .landscape)
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1]|", views: views);
            view.addConstraints("V:|[c2]|", views: views);
            
            view.addConstraints([
                backButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
                
                d20Button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
                
                refreshButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                refreshButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            ])
        }
        view.layoutSubviews()
    }
}
