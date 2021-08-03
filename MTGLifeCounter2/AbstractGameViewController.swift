//
//  AbstractGameViewController.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/07/16.
//  Copyright © 2016 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class AbstractGameViewController : UIViewController, PlayerViewControllerDelegate, DidTouchDelegate, UIPopoverPresentationControllerDelegate {
    var initialLifeTotal:Int { preconditionFailure("This method must be overridden")  }
    var configKey:String { preconditionFailure("This method must be overridden")  }
    
    var _players:[PlayerViewController] = []
    
    var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func d20ButtonPressed(_ sender: AnyObject) {
        // Load and configure your view controller.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "popupMenuViewController") as? PopupMenuViewController else {
            fatalError("storyboard can't instantiateViewController popupMenuViewController")
        }
        vc.preferredContentSize = CGSize(width: 260, height: 260)
         
        // Use the popover presentation style for your view controller.
        vc.modalPresentationStyle = .popover
        
        if let presentationController = vc.popoverPresentationController {
            presentationController.delegate = self
            presentationController.sourceView = (sender as! UIView)
        }
        
        vc.actionSelected = { action in
            
            let maxValue: Int
            var generator = DiceRollView.standardGenerator
            switch action {
            case .allPlayersD20:
                self.rollD20ForAllPlayers()
                return
            case .singleD20:
                maxValue = 20
            case .singleD12:
                maxValue = 12
            case .singleD10:
                maxValue = 10
            case .singleD8:
                maxValue = 8
            case .singleD6:
                maxValue = 6
            case .singleD4:
                maxValue = 4
            case .coinFlip:
                maxValue = 2
                if #available(iOS 13.0, *) {
                    let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
                    
                    let att = NSTextAttachment()
                    att.image = UIImage(systemName: "cross.circle.fill", withConfiguration: config)?.withTintColor(.lightGray)
                    let tailString = NSAttributedString(attachment: att)
                    
                    let att2 = NSTextAttachment()
                    att2.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)?.withTintColor(.yellow)
                    let headString = NSAttributedString(attachment: att2)
                    
                    generator = { (x:Int, final: Bool) -> NSAttributedString in
                        switch x { // +1 on random number has already been applied
                        case 1: return headString
                        case 2: return tailString
                        default: fatalError("invalid coin flip")
                        }
                    }
                }
                else {
                    generator = { (x:Int, final: Bool) -> NSAttributedString in
                        switch x { // +1 on random number has already been applied
                        case 1: return NSAttributedString(string: "H")
                        case 2: return NSAttributedString(string: "T")
                        default: fatalError("invalid coin flip")
                        }
                    }
                }
            }
            let value = Int(arc4random_uniform(UInt32(maxValue)))+1
            
            let diceRollView = DiceRollView.create(finalValue: value, max: maxValue, winner: false, numCells: 8, orientation: .normal, generator: generator) // TODO get the overall view orientation
            diceRollView.showInView(self.view, callbackDuration: 0.6, pauseDuration: 0.7, fadeDuration: 0.3) // slightly faster than the new-game one
        }

        // Present the view controller (in a popover).
        self.present(vc, animated: true, completion: nil)
    }
        
    func rollD20ForAllPlayers() {
        for (c, (num, winner)) in zip(_players, randomUntiedDiceRolls(_players.count, diceFaceCount: UInt(20))) {
            let diceRollView = DiceRollView.create(finalValue: Int(num), max: 20, winner: winner, numCells: 30, orientation: c.orientation)
            diceRollView.showInView(c.view) { // putting the dice roll view inside the playerView means it's auto-upside down
                if winner { // finalCallback after the animation pulse
                    c.isDiceRollWinner = true
                }
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        for p in _players {
            p.resetLifeTotal(initialLifeTotal)
        }
    }
    
    func colorDidChange(newColor: MtgColor, sender: PlayerViewController) {
        playerColorDidChange(deviceOrientation: view.bounds.size.orientation)
    }
    
    func playerColorDidChange(deviceOrientation: ContainerOrientation) {} // override point
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared as! Application
        app.didTouch = self // weak ref so don't really care about unassigning it
    }
    
    func didTouch() {
        for p in _players {
            p.isDiceRollWinner = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.isNavigationBarHidden = true
        
        do {
            let settings = try DataStore.getWithKey(configKey)
            
            for (idx, p) in _players.enumerated() {
                p.reset(lifeTotal: settings["player\(idx)"] as? NSNumber, color:settings["player\(idx)color"] as? NSNumber)
            }
        } catch { } // can't really do anything productive
        
        UIApplication.shared.isIdleTimerDisabled = true
        viewWillTransition(to: view.bounds.size, with: transitionCoordinator!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.isNavigationBarHidden = false
        
        var dict = [String:Int]()
        for (idx, p) in _players.enumerated() {
            dict["player\(idx)"] = p.lifeTotal
            dict["player\(idx)color"] = p.color.rawValue
        }
        
        do {
            try DataStore.setWithKey(configKey, value: dict)
        } catch { } // perhaps we could show the user an error message or something?
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let s = segue.identifier else { fatalError("segue identifier not set") }
        switch s {
        case "player1_embed", "player2_embed", "player3_embed", "player4_embed", "player5_embed":
            guard let viewController = segue.destination as? PlayerViewController else { return }
            viewController.resetLifeTotal(initialLifeTotal)
            viewController.delegate = self
            _players.append(viewController)
        default: fatalError("unhandled segue \(s)")
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setConstraints(for: size)
        // refresh statusBar color as things will move around
        playerColorDidChange(deviceOrientation: size.orientation)
        for player in _players {
            player.view?.setNeedsDisplay()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // override this for different layouts
    func setConstraints(for size:CGSize) {
        preconditionFailure("must be overridden")
    }
}

enum PopupAction {
    case allPlayersD20
    case singleD20
    case singleD12
    case singleD10
    case singleD8
    case singleD6
    case singleD4
    case coinFlip
}

class PopupMenuViewController : UIViewController {
    var actionSelected: ((PopupAction) -> ())?
    
    private func selectAction(_ action: PopupAction) {
        actionSelected?(action)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newGamePressed(_ sender: Any) {
        selectAction(.allPlayersD20)
    }
    @IBAction func htPressed(_ sender: Any) {
        selectAction(.coinFlip)
    }
    @IBAction func d4Pressed(_ sender: Any) {
        selectAction(.singleD4)
    }
    @IBAction func d6Pressed(_ sender: Any) {
        selectAction(.singleD6)
    }
    @IBAction func d8Pressed(_ sender: Any) {
        selectAction(.singleD8)
    }
    @IBAction func d10Pressed(_ sender: Any) {
        selectAction(.singleD10)
    }
    @IBAction func d12Pressed(_ sender: Any) {
        selectAction(.singleD12)
    }
    @IBAction func d20Pressed(_ sender: Any) {
        selectAction(.singleD20)
    }
}
