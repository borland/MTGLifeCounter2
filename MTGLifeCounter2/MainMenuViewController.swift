//
//  MainMenuViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 6/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class MainMenuViewController : UITableViewController {
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = .Black // white text
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 { // Roll D20
            let diceRollView = DiceRollView.create(UInt(arc4random_uniform(20) + 1))
            diceRollView.showInView(view, callbackDuration:1, pauseDuration:1.3)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}