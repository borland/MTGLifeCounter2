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
        
        let frame = CGRect(x: 50, y: 50, width: 300, height: 300)
        
        let menu = RadialColorPicker(frame: frame) { c in print("got \(c)") }
        view.addSubview(menu)
    }
}
