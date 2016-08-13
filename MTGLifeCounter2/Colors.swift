//
//  Colors.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 19/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum MtgColor : Int {
    case white, blue, black, red, green // basic
    case whiteBlue, blueBlack, blackRed, redGreen, greenWhite // allied
    case whiteBlack, blueRed, blackGreen, redWhite, greenBlue // enemy
    
    var displayName:String {
        get {
            switch self {
            case white: return "White"
            case blue: return "Blue"
            case black: return "Black"
            case red: return "Red"
            case green: return "Green"
            case whiteBlue: return "Azorius"
            case blueBlack: return "Dimir"
            case blackRed: return "Rakdos"
            case redGreen: return "Gruul"
            case greenWhite: return "Selesnya"
            case whiteBlack: return "Orzhov"
            case blueRed: return "Izzet"
            case blackGreen: return "Golgari"
            case redWhite: return "Boros"
            case greenBlue: return "Simic"
            }
        }
    }
    
    static func First() -> MtgColor {
        return white
    }
    
    static func Last() -> MtgColor {
        return greenBlue
    }
    
    func lookup(_ primary:Bool) -> UIColor {
        switch primary {
        case true:
            switch self {
            case white, whiteBlue, whiteBlack:
                return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            case blue, blueBlack, blueRed:
                return UIColor(red: 0.0, green: 0.22, blue: 0.72, alpha: 1)
            case black, blackRed, blackGreen:
                return UIColor(red: 0.12, green: 0.19, blue: 0.25, alpha: 1)
            case red, redGreen, redWhite:
                return UIColor(red: 0.84, green: 0.04, blue: 0.07, alpha: 1)
            case green, greenWhite, greenBlue:
                return UIColor(red: 0.15, green: 0.68, blue: 0.27, alpha: 1)
            }
        case false:
            switch self {
            case white, greenWhite, redWhite:
                return UIColor(red: 0.97, green: 0.92, blue: 0.9, alpha: 1)
            case blue, whiteBlue, greenBlue:
                return UIColor(red: 0.2, green: 0.30, blue: 1.00, alpha: 1)
            case black, blueBlack, whiteBlack:
                return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            case red, blackRed, blueRed:
                return UIColor(red: 0.78, green: 0.14, blue: 0.04, alpha: 1)
            case green, redGreen, blackGreen:
                return UIColor(red: 0.19, green: 0.66, blue: 0.20, alpha: 1)
            }
        }
    }
}
