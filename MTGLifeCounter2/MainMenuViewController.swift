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
            let diceRollView = DiceRollView(frame: view.frame, faceCount: 20)
            view.addSubview(diceRollView)
            
            diceRollView.roll(completion: { _ in diceRollView.removeFromSuperview() })
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}