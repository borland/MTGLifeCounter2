//
//  AbstractGameViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class AbstractGameViewController : UIViewController, PlayerViewControllerDelegate {
    var initialLifeTotal:Int { preconditionFailure("This method must be overridden")  }
    var configKey:String { preconditionFailure("This method must be overridden")  }
    
    var _players:[PlayerViewController] = []
    
    var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func d20ButtonPressed(_ sender: AnyObject) {
        for (c, (num, winner)) in zip(_players, randomUntiedDiceRolls(_players.count, diceFaceCount: UInt(20))) {
            let diceRollView = DiceRollView.create(num, winner:winner, orientation: c.orientation)
            diceRollView.showInView(c.view) // putting the dice roll view inside the playerView means it's auto-upside down
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        for p in _players {
            p.resetLifeTotal(initialLifeTotal)
        }
    }
    
    func colorDidChange(newColor: MtgColor, sender: PlayerViewController) {
        playerColorDidChange()
    }
    
    func playerColorDidChange() {} // override point
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.isNavigationBarHidden = true
        
        do {
            let settings = try DataStore.getWithKey(configKey)
            
            for (idx, p) in _players.enumerated() {
                p.reset(lifeTotal: settings["player\(idx)"] as? NSNumber, color:settings["player\(idx)color"] as? NSNumber)
            }
        } catch { } // can't really do anything productive
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.isNavigationBarHidden = false
        
        var dict = [String:Int]()
        for (idx, p) in _players.enumerated() {
            dict["player\(idx)"] = p.lifeTotal
            dict["player\(idx)color"] = p.color.rawValue
        }
        
        do {
            try DataStore.setWithKey(configKey, value: dict)
        } catch { } // perhaps we could show the user an error message or something?
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let s = segue.identifier else { fatalError("segue identifier not set") }
        switch s {
        case "player1_embed", "player2_embed", "player3_embed", "player4_embed", "player5_embed":
            guard let viewController = segue.destination as? PlayerViewController else { return }
            viewController.resetLifeTotal(initialLifeTotal)
            viewController.delegate = self
            _players.append(viewController)
        default: fatalError("unhandled segue \(s)")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraintsFor(traitCollection)
        playerColorDidChange() // refresh statusBar color as things moved around
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // override this for different layouts
    func setConstraintsFor(_ traitCollection:UITraitCollection) {
        preconditionFailure("must be overridden")
    }
}
