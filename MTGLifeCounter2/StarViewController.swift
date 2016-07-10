//
//  StarViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 10/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class StarViewController : UIViewController {
    var initialLifeTotal:Int { get { return 20 } }
    var configKey:String {get { return "star" } }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var c4: UIView!
    @IBOutlet weak var c5: UIView!
    
    private var _players:[PlayerViewController] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        for p in _players {
            p.resetLifeTotal(initialLifeTotal)
        }
    }
    
    @IBAction func d20ButtonPressed(sender: AnyObject) {
//        for (c, (num, winner)) in zip([c1, c2, c3], randomUntiedDiceRolls(3, diceFaceCount: UInt(20))) {
//            let diceRollView = DiceRollView.create(num, winner:winner)
//            diceRollView.showInView(c)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addConstraints([
            NSLayoutConstraint(item: backButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 44),
            NSLayoutConstraint(item: backButton, attribute: .Height, relatedBy: .Equal, toItem: backButton, attribute: .Width, multiplier: 1, constant: 0)
            ])
        
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = 22
        backButton.backgroundColor = GlobalTintColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBarHidden = true
        
        do {
            let settings = try DataStore.getWithKey(configKey)
            
            for (idx, p) in _players.enumerate() {
                resetPlayerViewController(p,
                                          lifeTotal:settings["player\(idx)"] as? NSNumber,
                                          color:settings["player\(idx)color"] as? NSNumber)
            }
            
        } catch { } // perhaps we could show the user an error message or something?
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
            viewController.displaySize = .Small
            _players.append(viewController)
        default: fatalError("unhandled segue")
        }
        
        if(_players.count == 5) {
            setConstraintsFor(traitCollection)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraintsFor(traitCollection)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    private func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints as [NSLayoutConstraint]
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(c4!),
            constraints.affectingView(c5!),
            constraints.affectingView(backButton!))
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!, "c4":c4!, "c5":c5!]
        
//        view.addConstraints("|[toolbar]|", views: views)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
//            view.addConstraints("V:|[c1(==c2)][c2(==c3)][c3(==c1)][toolbar(34)]|", views: views)
//            view.addConstraints("|[c1]|", views: views)
//            view.addConstraints("|[c2]|", views: views)
//            view.addConstraints("|[c3]|", views: views)
            break
            
        default:
            for p in _players {
                p.buttonOrientation = .Horizontal // force buttons on the side even though we don't normally do this in landscape
            }
            if _players.count == 5 {
                _players[3].innerHorizontalOffset = 25
                _players[4].innerHorizontalOffset = -25
            }
            
            // first row horizontally
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            
            // second row horizontally
            view.addConstraints("|[c4(==c5)][c5(==c4)]|", views: views)
            
            // two rows vertically (just align the leftmost and let the others stick to those)
            view.addConstraints("V:|[c1][c4]|", views: views)
            
            view.addAllConstraints(
                // all equal height
                [c2, c3, c4, c5].map { c1.heightAnchor.constraintEqualToAnchor($0.heightAnchor) },
                
                // align tops of two rows
                [c2, c3].map { c1.topAnchor.constraintEqualToAnchor($0.topAnchor) },
                [ c5.topAnchor.constraintEqualToAnchor(c4.topAnchor) ],
                
                // back button
                [
                    view.leftAnchor.constraintEqualToAnchor(backButton.leftAnchor, constant: 8)
                
                ]
            )
        }
    }
}

// swift 2.2 compiler +'ing more than 3 arrays together takes minutes to COMPILE, so we don't + them
func concat<T>(arrays: [[T]]) -> [T] {
    var result = [T]()
    for array in arrays {
        result.appendContentsOf(array)
    }
    return result
}

