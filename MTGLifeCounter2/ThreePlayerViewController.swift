//
//  ThreePlayerViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 8/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class ThreePlayerViewController : AbstractGameViewController {
    override var initialLifeTotal: Int { return 20 }
    override var configKey:String { return "threePlayer" }
    
    @IBOutlet weak var c1: UIView!
    @IBOutlet weak var c2: UIView!
    @IBOutlet weak var c3: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func setConstraintsFor(traitCollection:UITraitCollection) {
        let constraints = view.constraints
        view.removeAllConstraints(
            constraints.affectingView(c1!),
            constraints.affectingView(c2!),
            constraints.affectingView(c3!),
            constraints.affectingView(toolbar!))
        
        let views = ["c1":c1!, "c2":c2!, "c3":c3!, "toolbar":toolbar!]
        
        view.addConstraints("|[toolbar]|", views: views)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular): // phone in portrait
            view.addConstraints("V:|[c1(==c2)][c2(==c3)][c3(==c1)][toolbar(34)]|", views: views)
            view.addConstraints("|[c1]|", views: views)
            view.addConstraints("|[c2]|", views: views)
            view.addConstraints("|[c3]|", views: views)
            
        default:
            view.addConstraints("|[c1(==c2)][c2(==c3)][c3(==c1)]|", views: views)
            view.addConstraints("V:|[c1][toolbar(34)]|", views: views)
            view.addConstraints("V:|[c2][toolbar(34)]|", views: views)
            view.addConstraints("V:|[c3][toolbar(34)]|", views: views)
        }
    }
}