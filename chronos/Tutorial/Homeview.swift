//
//  Homeview.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit
class HomeView: GradientView {
    @IBOutlet var tutorialContainer: UIView!
    @IBOutlet var dismiss: UIButton!
    /// Set up the animation that draws our logo and brings in our two buttons smoothly.
    override func didMoveToSuperview() {
        
        //tutorialContainer.alpha = 0
        //dismiss.alpha = 0
        
    }
    func showTour() {
        tutorialContainer.fade(to: 1, delay: 0.5, duration: 0.5)
        dismiss.fade(to: 1, delay: 0.5, duration: 0.5)
    }
    func fadeTour() {
        tutorialContainer.fade(to: 0, delay: 0.5, duration: 0.5)
        dismiss.fade(to: 0, delay: 0.5, duration: 0.5)
    }
   
}
