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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func d20ButtonPressed(sender: UIBarButtonItem) {
        let diceRollView = DiceRollView(frame: view.frame, faceCount: 20)
        view.addSubview(diceRollView)
        
        diceRollView.roll(completion: { _ in diceRollView.removeFromSuperview() })
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        if let vc = player1 {
            vc.lifeTotal = initialLifeTotal
        }
        if let vc = player2 {
            vc.lifeTotal = initialLifeTotal
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
        
        if let settings = DataStore.getWithKey(configKey) {
            if let p1 = player1 {
                if let x = (settings["player1"] as? NSNumber) {
                    p1.lifeTotal = x.integerValue
                }
                if let x = (settings["player1color"] as? NSNumber) {
                    if let color = MtgColor.fromRaw(x.integerValue) {
                        p1.color = color
                    }
                }
            }
            if let p2 = player2 {
                if let x = (settings["player2"] as? NSNumber) {
                    p2.lifeTotal = x.integerValue
                }
                if let x = (settings["player2color"] as? NSNumber) {
                    if let color = MtgColor.fromRaw(x.integerValue) {
                        p2.color = color
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController!.navigationBarHidden = false
        
        if let p1 = player1 {
            if let p2 = player2 {
                let settings = [
                    "player1": p1.lifeTotal,
                    "player1color": p1.color.toRaw(),
                    "player2": p2.lifeTotal,
                    "player2color": p2.color.toRaw()]
                
                DataStore.setWithKey(configKey, value: settings)
            }
        }
    }
    
private
    var player1:PlayerViewController?
    var player2:PlayerViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "player1_embed":
            if let viewController = segue.destinationViewController as? PlayerViewController {
                player1 = viewController
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
                player2 = viewController
                viewController.playerName = "P2"
                viewController.lifeTotal = initialLifeTotal
            }
        default: assertionFailure("unhandled segue")
        }
        
        if(player1 != nil && player2 != nil) {
            setConstraintsFor(interfaceOrientation)
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setConstraintsFor(toInterfaceOrientation)
        
        if let p1 = player1 {
            switch toInterfaceOrientation {
            case .Unknown, .Portrait, .PortraitUpsideDown:
                p1.isUpsideDown = true
            case .LandscapeLeft, .LandscapeRight:
                p1.isUpsideDown = false
            }
        }
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        view.removeConstraints(view.constraints()) // remove ALL constraints
    
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
    }
}