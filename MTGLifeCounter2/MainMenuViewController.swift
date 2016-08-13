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
        self.navigationController?.navigationBar.barStyle = .black // white text
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 { // Roll D20
            let diceRollView = DiceRollView.create(UInt(arc4random_uniform(20) + 1), winner:false)
            diceRollView.showInView(view, callbackDuration:1, pauseDuration:1.3)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
