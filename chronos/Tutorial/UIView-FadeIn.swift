//
//  UIView-FadeIn.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

extension UIView {
    /// Animates a UIView with a specific delay and duration.
    func fade(to alpha: CGFloat, delay: TimeInterval = 0, duration: TimeInterval, then completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = alpha
        }, completion: { _ in
            completion?()
        })
    }
}
