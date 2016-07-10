//
//  AbstractGameViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class AbstractGameViewController : UIViewController {
    var initialLifeTotal:Int { preconditionFailure("This method must be overridden")  }
    var configKey:String { preconditionFailure("This method must be overridden")  }
    var containers:[UIView] { preconditionFailure("This method must be overridden")  }
    
    var _players:[PlayerViewController] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func d20ButtonPressed(sender: UIBarButtonItem) {
        for (c, (num, winner)) in zip(containers, randomUntiedDiceRolls(containers.count, diceFaceCount: UInt(20))) {
            let diceRollView = DiceRollView.create(num, winner:winner)
            diceRollView.showInView(c)
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        for p in _players {
            p.resetLifeTotal(initialLifeTotal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBarHidden = true
        
        do {
            let settings = try DataStore.getWithKey(configKey)
            
            for (idx, p) in _players.enumerate() {
                p.reset(lifeTotal: settings["player\(idx)"] as? NSNumber, color:settings["player\(idx)color"] as? NSNumber)
            }
        } catch { } // can't really do anything productive
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.navigationBarHidden = false
        
        var dict = [String:Int]()
        for (idx, p) in _players.enumerate() {
            dict["player\(idx)"] = p.lifeTotal
            dict["player\(idx)color"] = p.color.rawValue
        }
        
        do {
            try DataStore.setWithKey(configKey, value: dict)
        } catch { } // perhaps we could show the user an error message or something?
        
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let s = segue.identifier else { fatalError("segue identifier not set") }
        switch s {
        case "player1_embed", "player2_embed", "player3_embed", "player4_embed", "player5_embed":
            guard let viewController = segue.destinationViewController as? PlayerViewController else { return }
            viewController.resetLifeTotal(initialLifeTotal)
            _players.append(viewController)
        default: fatalError("unhandled segue \(s)")
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraintsFor(traitCollection)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // override this for different layouts
    func setConstraintsFor(traitCollection:UITraitCollection) {
        preconditionFailure("must be overridden")
    }
}
