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
    let initialLifeTotal:Int = 20
    
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func d20ButtonPressed(sender: UIBarButtonItem) {
        let diceRollView = DiceRollView(frame: view.frame, faceCount: 20)
        view.addSubview(diceRollView)
        
        diceRollView.roll(completion: { _ in diceRollView.removeFromSuperview() })
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        if let vc = self.player1 {
            vc.lifeTotal = initialLifeTotal
            vc.selectRandomColor()
        }
        if let vc = self.player2 {
            vc.lifeTotal = initialLifeTotal
            vc.selectRandomColor()
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueName = segue.identifier
        if segueName == "player1_embed" {
            if let viewController = segue.destinationViewController as? PlayerViewController {
                self.player1 = viewController
                viewController.playerName = "P1"
                viewController.lifeTotal = self.initialLifeTotal
                
                switch (self.interfaceOrientation) {
                case .Portrait, .PortraitUpsideDown:
                    viewController.isUpsideDown = true
                case .Unknown, .LandscapeLeft, .LandscapeRight:
                    viewController.isUpsideDown = false
                }
            }
            
        }
        else if segueName == "player2_embed" {
            if let viewController = segue.destinationViewController as? PlayerViewController {
                self.player2 = viewController
                viewController.playerName = "P2"
                viewController.lifeTotal = self.initialLifeTotal
            }
        }
        
        if(self.player1 != nil && self.player2 != nil) {
            self.setConstraintsFor(self.interfaceOrientation)
        }
    }
    
    func setConstraintsFor(orientation:UIInterfaceOrientation) {
        view.removeConstraints(view.constraints()) // remove ALL constraints
    
        let views = ["c1":container1!, "c2":container2!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (orientation) {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            view.addConstraints("V:|[c1(==c2)][toolbar(33)][c2(==c1)]|", views: views);
            view.addConstraints("|[c1]|", views: views);
            view.addConstraints("|[c2]|", views: views);
            
        case .LandscapeLeft, .LandscapeRight:
            view.addConstraints("|[c1(==c2)][c2(==c1)]|", views: views);
            view.addConstraints("V:|[c1][toolbar(33)]|", views: views);
            view.addConstraints("V:|[c2][toolbar(33)]|", views: views);
        }
    }
}