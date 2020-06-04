//
//  LaunchScreenViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.alpha = 0.25
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //logo animation
        UIView.animateKeyframes(withDuration: 3, delay: 0.1, options: [],animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.logo.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.9) {
                self.logo.alpha = 0
            }
            
        }, completion: { (true) in
            self.performSegue(withIdentifier: "launchToHome", sender: nil)
        })
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
