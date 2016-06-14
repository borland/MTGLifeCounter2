//
//  TestViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 15/06/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class TestViewController : UIViewController {
    
    override func viewDidLoad() {
        let menu = RadialColorPicker(radius: 250)
        
        view.addSubview(menu)
        
        menu.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 50).active = true
        menu.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 50).active = true
    }
}
