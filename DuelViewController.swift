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
    
private
    var player1:PlayerViewController?
    var player2:PlayerViewController?
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func d20ButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueName = segue.identifier;
        if segueName == "player1_embed" {
            if let viewController = segue.destinationViewController as? PlayerViewController {
                self.player1 = viewController
                viewController.playerName = "P1"
                viewController.lifeTotal = self.initialLifeTotal
            }
            
            switch (self.interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                self.player1.isUpsideDown = YES;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                self.player1.isUpsideDown = NO;
                break;
            }
            
        }
        else if ([segueName isEqualToString: @"player2_embed"]) {
            self.player2 = (MTGPlayerViewController *) [segue destinationViewController];
            self.player2.playerName = @"P2";
            self.player2.lifeTotal = self.initialLifeTotal;
        }
        
        if(self.player1 && self.player2) {
            [self setConstraintsFor:self.interfaceOrientation];
        }

    }
}