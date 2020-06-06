//
//  HomeViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit
import SwiftEntryKit
class HomeViewController: UIViewController, Storyboarded {
    @IBAction func help(_ sender: Any) {
        guard let view = self.view as? HomeView else {
            fatalError("WelcomeViewController doesn't have a WelcomeView as its view.")
        }
        view.showTour()
    }

    @IBAction func skipTour(_ sender: Any) {
        guard let view = self.view as? HomeView else {
            fatalError("WelcomeViewController doesn't have a WelcomeView as its view.")
        }
        view.fadeTour()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
