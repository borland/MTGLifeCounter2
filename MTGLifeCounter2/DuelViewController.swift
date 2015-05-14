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
        for (c, r) in zip([container1, container2], randomUntiedDiceRolls(2, UInt(20))) {
            let diceRollView = DiceRollView.create(r)
            
            if c == container1 {
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
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        if let p1 = _player1, let p2 = _player2 {
            p1.resetLifeTotal(initialLifeTotal)
            p2.resetLifeTotal(initialLifeTotal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
        
        if let settings = DataStore.getWithKey(configKey), let p1 = _player1, let p2 = _player2 {
            resetPlayerViewController(p1,
                withLifeTotal:settings["player1"] as? NSNumber,
                color:settings["player1color"] as? NSNumber)

            resetPlayerViewController(p2,
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
                    viewController.resetLifeTotal(initialLifeTotal)
                    
                    switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
                    case (.Compact, .Regular): // phone in portrait
                        viewController.isUpsideDown = true
                    default:
                        viewController.isUpsideDown = false
                    }
                }
            case "player2_embed":
                if let viewController = segue.destinationViewController as? PlayerViewController {
                    _player2 = viewController
                    viewController.playerName = "P2"
                    viewController.resetLifeTotal(initialLifeTotal)
                }
            default: assertionFailure("unhandled segue")
            }
            
            if(_player1 != nil && _player2 != nil) {
                setConstraintsFor(traitCollection)
            }
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if let p1 = _player1 {
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.Compact, .Regular): // phone in portrait
                p1.isUpsideDown = true
            default:
                p1.isUpsideDown = false
            }
        }
        
        setConstraintsFor(traitCollection)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    private func setConstraintsFor(traitCollection:UITraitCollection) {
        
        let cx = view.constraints() as! [NSLayoutConstraint]
        view.removeConstraints(
            constraints(cx, affectingView:container1!) +
                constraints(cx, affectingView:container2!) +
                constraints(cx, affectingView:toolbar))
        
        let views = ["c1":container1!, "c2":container2!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular):
            view.addConstraints("V:|[c1(==c2)][toolbar(40)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
        default:
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1][toolbar(34)]|", views: views);
            view.addConstraints("V:|[c2][toolbar(34)]|", views: views);
        }
        view.layoutSubviews()
    }
}