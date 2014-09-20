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
    case White, Blue, Black, Red, Green // basic
    case WhiteBlue, BlueBlack, BlackRed, RedGreen, GreenWhite // allied
    case WhiteBlack, BlueRed, BlackGreen, RedWhite, GreenBlue // enemy
    
    var displayName:String {
        get {
            switch self {
            case White: return "White"
            case Blue: return "Blue"
            case Black: return "Black"
            case Red: return "Red"
            case Green: return "Green"
            case WhiteBlue: return "Azorius"
            case BlueBlack: return "Dimir"
            case BlackRed: return "Rakdos"
            case RedGreen: return "Gruul"
            case GreenWhite: return "Selesnya"
            case WhiteBlack: return "Orzhov"
            case BlueRed: return "Izzet"
            case BlackGreen: return "Golgari"
            case RedWhite: return "Boros"
            case GreenBlue: return "Simic"
            }
        }
    }
    
    static func First() -> MtgColor {
        return White
    }
    
    static func Last() -> MtgColor {
        return GreenBlue
    }
    
    func lookup(primary:Bool) -> UIColor {
        switch primary {
        case true:
            switch self {
            case White, WhiteBlue, WhiteBlack:
                return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            case Blue, BlueBlack, BlueRed:
                return UIColor(red: 0.0, green: 0.22, blue: 0.72, alpha: 1)
            case Black, BlackRed, BlackGreen:
                return UIColor(red: 0.12, green: 0.19, blue: 0.25, alpha: 1)
            case Red, RedGreen, RedWhite:
                return UIColor(red: 0.84, green: 0.04, blue: 0.07, alpha: 1)
            case Green, GreenWhite, GreenBlue:
                return UIColor(red: 0.15, green: 0.68, blue: 0.27, alpha: 1)
            }
        case false:
            switch self {
            case White, GreenWhite, RedWhite:
                return UIColor(red: 0.97, green: 0.92, blue: 0.9, alpha: 1)
            case Blue, WhiteBlue, GreenBlue:
                return UIColor(red: 0.2, green: 0.30, blue: 1.00, alpha: 1)
            case Black, BlueBlack, WhiteBlack:
                return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            case Red, BlackRed, BlueRed:
                return UIColor(red: 0.78, green: 0.14, blue: 0.04, alpha: 1)
            case Green, RedGreen, BlackGreen:
                return UIColor(red: 0.19, green: 0.66, blue: 0.20, alpha: 1)
            }
        default:
            fatalError("Bool was not true or false. what?")
        }
    }
}
