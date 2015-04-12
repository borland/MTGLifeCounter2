//
//  DuelViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class DuelViewController : UIViewController {
    var initialLifeTotal:Int { get { return 20 } }
    var configKey:String {get { return "duel" } }
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    private var _player1:PlayerViewController?
    private var _player2:PlayerViewController?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func d20ButtonPressed(sender: UIBarButtonItem) {
        for c in [container1, container2] {
            let diceRollView = DiceRollView(frame: c.frame, faceCount: 20)
            view.addSubview(diceRollView)
            
            if c == container1 {
                switch (interfaceOrientation) {
                case .Portrait, .PortraitUpsideDown:
                    diceRollView.isUpsideDown = true
                case .Unknown, .LandscapeLeft, .LandscapeRight:
                    diceRollView.isUpsideDown = false
                }
            }
            
            diceRollView.roll(duration:2.5, completion: { _ in diceRollView.removeFromSuperview() })
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        if let p1 = _player1, let p2 = _player2 {
            p1.lifeTotal = initialLifeTotal
            p2.lifeTotal = initialLifeTotal
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
        
        if let settings = DataStore.getWithKey(configKey), let p1 = _player1, let p2 = _player2 {
            updatePlayerViewController(p1,
                withLifeTotal:settings["player1"] as? NSNumber,
                color:settings["player1color"] as? NSNumber)

            updatePlayerViewController(p2,
                withLifeTotal:settings["player2"] as? NSNumber,
                color:settings["player2color"] as? NSNumber)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController!.navigationBarHidden = false
        
        if let p1 = _player1, let p2 = _player2 {
            DataStore.setWithKey(configKey, value: [
                "player1": p1.lifeTotal,
                "player1color": p1.color.rawValue,
                "player2": p2.lifeTotal,
                "player2color": p2.color.rawValue])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let s = segue.identifier {
            switch s {
            case "player1_embed":
                if let viewController = segue.destinationViewController as? PlayerViewController {
                    _player1 = viewController
                    viewController.playerName = "P1"
                    viewController.lifeTotal = initialLifeTotal
                    
                    switch (interfaceOrientation) {
                    case .Portrait, .PortraitUpsideDown:
                        viewController.isUpsideDown = true
                    case .Unknown, .LandscapeLeft, .LandscapeRight:
                        viewController.isUpsideDown = false
                    }
                }
            case "player2_embed":
                if let viewController = segue.destinationViewController as? PlayerViewController {
                    _player2 = viewController
                    viewController.playerName = "P2"
                    viewController.lifeTotal = initialLifeTotal
                }
            default: assertionFailure("unhandled segue")
            }
            
            if(_player1 != nil && _player2 != nil) {
                setConstraintsFor(interfaceOrientation)
            }
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        if let p1 = _player1 {
            switch toInterfaceOrientation {
            case .Unknown, .Portrait, .PortraitUpsideDown:
                p1.isUpsideDown = true
            case .LandscapeLeft, .LandscapeRight:
                p1.isUpsideDown = false
            }
        }
        
        setConstraintsFor(toInterfaceOrientation)
    }
    
    private func setConstraintsFor(orientation:UIInterfaceOrientation) {
        let cx = view.constraints() as! [NSLayoutConstraint]
        view.removeConstraints(
            constraints(cx, affectingView:container1!) +
                constraints(cx, affectingView:container2!) +
                constraints(cx, affectingView:toolbar))
        
        let views = ["c1":container1!, "c2":container2!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (orientation) {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            view.addConstraints("V:|[c1(==c2)][toolbar(40)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
        case .LandscapeLeft, .LandscapeRight:
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1][toolbar(34)]|", views: views);
            view.addConstraints("V:|[c2][toolbar(34)]|", views: views);
        }
        view.layoutSubviews()
    }
}