//
//  UIApplication-activetraitcollection.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    /** Attempts to return the active trait collection for the first window, or an empty trait collection otherwise. Because this specifically uses the first window for the trait collection, it should only be used for system-wide settings – dark mode, scale, etc.
     */
    static var activeTraitCollection: UITraitCollection {
        if let activeTraits = UIApplication.shared.windows.first?.traitCollection {
            return activeTraits
        } else {
            return UITraitCollection()
        }
    }
}
