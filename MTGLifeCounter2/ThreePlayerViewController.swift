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
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        if let vc = player1 {
            vc.lifeTotal = initialLifeTotal
            vc.selectRandomColor()
        }
        if let vc = player2 {
            vc.lifeTotal = initialLifeTotal
            vc.selectRandomColor()
        }
        if let vc = player3 {
            vc.lifeTotal = initialLifeTotal
            vc.selectRandomColor()
        }
    }
    
    @IBAction func d20ButtonPressed(sender: AnyObject) {
        let diceRollView = DiceRollView(frame: view.frame, faceCount: 20)
        view.addSubview(diceRollView)
        
        diceRollView.roll(completion: { _ in diceRollView.removeFromSuperview() })
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController!.navigationBarHidden = false
    }
    
private
    var player1:PlayerViewController?
    var player2:PlayerViewController?
    var player3:PlayerViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "player1_embed":
            if let viewController = segue.destinationViewController as? PlayerViewController {
                player1 = viewController
                viewController.playerName = "P1"
                viewController.lifeTotal = initialLifeTotal
            }
            
        case "player2_embed":
            if let viewController = segue.destinationViewController as? PlayerViewController {
                player2 = viewController
                viewController.playerName = "P2"
                viewController.lifeTotal = initialLifeTotal
            }
        case "player3_embed":
            if let viewController = segue.destinationViewController as? PlayerViewController {
                player3 = viewController
                viewController.playerName = "P3"
                viewController.lifeTotal = initialLifeTotal
            }
        default: assertionFailure("unhandled segue")
        }
        
        if(player1 != nil && player2 != nil && player3 != nil) {
            setConstraintsFor(interfaceOrientation)
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setConstraintsFor(toInterfaceOrientation)
        
        for x in [player1, player2, player3] {
            if let vc = x {
                vc.view.setNeedsDisplay()
            }
        }
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        view.removeConstraints(view.constraints()) // remove ALL constraints
        
        let views = ["c1":container1!, "c2":container2!, "c3":container3!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (orientation) {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            view.addConstraints("V:|[c1(==c2)][c2(==c3)][c3(==c1)][toolbar(40)]|", views: views)
            view.addConstraints("|[c1]|", views: views)
            view.addConstraints("|[c2]|", views: views)
            view.addConstraints("|[c3]|", views: views)
            
        case .LandscapeLeft, .LandscapeRight:
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            view.addConstraints("V:|[c1][toolbar(33)]|", views: views)
            view.addConstraints("V:|[c2][toolbar(33)]|", views: views)
            view.addConstraints("V:|[c3][toolbar(33)]|", views: views)
        }
    }
}