//
//  Utility.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 4/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation

func unbiasedRandom(bound:Int32)->Int32 {
    let d = Double(random()) / Double(RAND_MAX)
    return Int32(d * Double(bound));
}