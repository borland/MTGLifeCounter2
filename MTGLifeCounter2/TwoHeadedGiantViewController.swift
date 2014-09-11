//
//  TwoHeadedGiantViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 8/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class TwoHeadedGiantViewController : DuelViewController {
    // we don't need any IBOutlets etc here, they're all wired in IB to
    // things with the same name as those in the base class 
    // (I ctrl+dragged in IB to set up the outlet, then deleted the line of code)
    
    override var initialLifeTotal:Int { get { return 30 } }
}