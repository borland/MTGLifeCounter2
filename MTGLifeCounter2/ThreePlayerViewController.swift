//
//  ThreePlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 8/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class ThreePlayerViewController : UIViewController {
    var initialLifeTotal:Int { get { return 20 } }
    var configKey:String {get { return "threePlayer" } }
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    private var _player1:PlayerViewController?
    private var _player2:PlayerViewController?
    private var _player3:PlayerViewController?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        if let p1 = _player1, let p2 = _player2, let p3 = _player3 {
            p1.resetLifeTotal(initialLifeTotal)
            p2.resetLifeTotal(initialLifeTotal)
            p3.resetLifeTotal(initialLifeTotal)
        }
    }
    
    @IBAction func d20ButtonPressed(sender: AnyObject) {
        for c in [container1, container2, container3] {
            let diceRollView = DiceRollView.create(UInt(arc4random_uniform(20) + 1))
            
            diceRollView.showInView(c, duration:2.5)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
        
        if let settings = DataStore.getWithKey(configKey), let p1 = _player1, let p2 = _player2, let p3 = _player3 {
            resetPlayerViewController(p1,
                withLifeTotal:settings["player1"] as? NSNumber,
                color:settings["player1color"] as? NSNumber)
            
            resetPlayerViewController(p2,
                withLifeTotal:settings["player2"] as? NSNumber,
                color:settings["player2color"] as? NSNumber)
            
            resetPlayerViewController(p3,
                withLifeTotal:settings["player3"] as? NSNumber,
                color:settings["player3color"] as? NSNumber)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController!.navigationBarHidden = false
        
        if let p1 = _player1, let p2 = _player2, let p3 = _player3 {
            DataStore.setWithKey(configKey, value: [
                "player1": p1.lifeTotal,
                "player1color": p1.color.rawValue,
                "player2": p2.lifeTotal,
                "player2color": p2.color.rawValue,
                "player3": p3.lifeTotal,
                "player3color": p3.color.rawValue])
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
                }
                
            case "player2_embed":
                if let viewController = segue.destinationViewController as? PlayerViewController {
                    _player2 = viewController
                    viewController.playerName = "P2"
                    viewController.resetLifeTotal(initialLifeTotal)
                }
            case "player3_embed":
                if let viewController = segue.destinationViewController as? PlayerViewController {
                    _player3 = viewController
                    viewController.playerName = "P3"
                    viewController.resetLifeTotal(initialLifeTotal)
                }
            default: assertionFailure("unhandled segue")
            }
        }
        
        if(_player1 != nil && _player2 != nil && _player3 != nil) {
            setConstraintsFor(traitCollection)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        setConstraintsFor(traitCollection)
    }
    
    private func setConstraintsFor(traitCollection:UITraitCollection) {
        let cx = view.constraints() as! [NSLayoutConstraint]
        view.removeConstraints(
            constraints(cx, affectingView:container1!) +
            constraints(cx, affectingView:container2!) +
            constraints(cx, affectingView:container3!) +
            constraints(cx, affectingView:toolbar))
        
        let views = ["c1":container1!, "c2":container2!, "c3":container3!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            view.addConstraints("V:|[c1(==c2)][c2(==c3)][c3(==c1)][toolbar(34)]|", views: views)
            view.addConstraints("|[c1]|", views: views)
            view.addConstraints("|[c2]|", views: views)
            view.addConstraints("|[c3]|", views: views)
            
        default:
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            view.addConstraints("V:|[c1][toolbar(34)]|", views: views)
            view.addConstraints("V:|[c2][toolbar(34)]|", views: views)
            view.addConstraints("V:|[c3][toolbar(34)]|", views: views)
        }
    }
}