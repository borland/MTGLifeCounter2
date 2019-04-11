//
//  main.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 29/01/19.
//  Copyright © 2019 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

protocol DidTouchDelegate : class {
    func didTouch()
}

class Application : UIApplication {
    
    // global touch handler
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if event.type == .touches, let touchDelegate = self.didTouch {
            touchDelegate.didTouch()
        }
    }
    
    // only support one active handler
    weak var didTouch : DidTouchDelegate? = nil
}


let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv)
    .bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(Application.self), NSStringFromClass(AppDelegate.self))
