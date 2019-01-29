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
            p.displaySize = .small
        }
    }
    
    override func playerColorDidChange(deviceOrientation: ContainerOrientation) {
        if(_players.count != 5) { return } // gets called spuriously during load
        
        switch (deviceOrientation,
                _players[0].color, _players[1].color, _players[2].color, _players[3].color, _players[4].color) {
        case (.portrait, .white, _, _, _, _), // portrait, top VC is white
        (.landscape, _, .white, _, _, _): // landscape, middle white
            statusBarStyle = .default
        default:
            statusBarStyle = .lightContent
        }
    }
    
    override func setConstraints(for size: CGSize) {
        let constraints = view.constraints as [NSLayoutConstraint]
        let toRemove = [c1!, c2!, c3!, c4!, c5!, backButton!, refreshButton!, d20Button!].flatMap{ constraints.affectingView($0) }
        view.removeAllConstraints(toRemove)
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!, "c4":c4!, "c5":c5!]
        assert(_players.count == 5) // called before view loaded?
        
        for p in _players {
            p.buttonPosition = .rightLeft // force buttons on the side even though we don't normally do this in landscape
            p.innerHorizontalOffset = 0
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        if size.orientation == .portrait {
            _players[0].orientation = .upsideDown
            _players[0].buttonPosition = .leftRight
            
            _players[1].orientation = .right
            _players[1].buttonPosition = .aboveBelow
            
            _players[2].orientation = .right
            _players[2].buttonPosition = .aboveBelow
            
            _players[3].orientation = .left
            _players[3].buttonPosition = .belowAbove
            
            _players[4].orientation = .left
            _players[4].buttonPosition = .belowAbove
            
          view.addConstraints([
                // c1 fills horizontal
                c1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                c1.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                // c4, c2 (weird order is so it lines up with landscape view)
                c4.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                c2.leadingAnchor.constraint(equalTo: c4.trailingAnchor),
                c2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                c4.widthAnchor.constraint(equalTo: c2.widthAnchor),
                c4.heightAnchor.constraint(equalTo: c2.heightAnchor),
                c4.topAnchor.constraint(equalTo: c2.topAnchor),
                
                // c3, c5 (order reversed for some reason)
                c5.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                c3.leadingAnchor.constraint(equalTo: c5.trailingAnchor),
                c3.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                c5.widthAnchor.constraint(equalTo: c3.widthAnchor),
                c5.heightAnchor.constraint(equalTo: c3.heightAnchor),
                c5.topAnchor.constraint(equalTo: c3.topAnchor),
                
                // stack the left row all vertically
                c1.topAnchor.constraint(equalTo: view.topAnchor),
                c4.topAnchor.constraint(equalTo: c1.bottomAnchor),
                c5.topAnchor.constraint(equalTo: c4.bottomAnchor),
                c5.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                // top view gets less space (not 33%) because it's wider, other views split evenly
                c1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28),
                // second row gets a bit more space as they're overlapped by buttons
                c4.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.38),
                
                // buttons
                backButton.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 8),
                backButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                d20Button.centerXAnchor.constraint(equalTo: c1.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: c1.bottomAnchor),
                
                refreshButton.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -8),
                refreshButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor)
            ])
        }
        else { // landscape view
            assert(size.orientation == .landscape)
            
            _players[0].orientation = .upsideDown
            _players[1].orientation = .upsideDown
            _players[2].orientation = .upsideDown
            _players[3].orientation = .normal
            _players[4].orientation = .normal
            
            _players[3].innerHorizontalOffset = 20
            _players[4].innerHorizontalOffset = -20
            
            // first row horizontally
            view.addConstraints("H:|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            
            // second row horizontally
            view.addConstraints("H:|[c4(==c5)][c5(==c4)]|", views: views)
            
            view.addAllConstraints(
                // stack two rows vertically (just align the leftmost and let the others stick to those)
                // top row gets 55%, not 50 due to space taken up by clock
                [
                    c1.topAnchor.constraint(equalTo: view.topAnchor),
                    c1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55),
                    
                    c4.topAnchor.constraint(equalTo: c1.bottomAnchor),
                    c4.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ],
                
                // all top row equal height and top aligned
                [c2, c3].map { $0.heightAnchor.constraint(equalTo: c1.heightAnchor) },
                [c2, c3].map { $0.topAnchor.constraint(equalTo: c1.topAnchor) },
                
                // second row equal height and top aligned
                [
                c5.heightAnchor.constraint(equalTo: c4.heightAnchor),
                c5.topAnchor.constraint(equalTo: c4.topAnchor),

                // back button
                backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
                backButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),

                // refresh button
                refreshButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
                refreshButton.centerYAnchor.constraint(equalTo: c1.bottomAnchor),

                // d20 button
                d20Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                d20Button.centerYAnchor.constraint(equalTo: c1.bottomAnchor)
                ]
            )
        }
    }
}
