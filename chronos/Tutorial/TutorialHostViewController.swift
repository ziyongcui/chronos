//
//  TutorialHostViewController.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
import UIKit

class TutorialHostViewController: UIViewController {
    @IBOutlet var pageControl: UIPageControl!

    /// Configures our child so that it can report back how many pages if contains and when page changes happen so we can update the page control.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let child = segue.destination as? TutorialPageViewController {
            //Some property on ChildVC that needs to be set
            child.pageChangeDelegate = self
        }
    }

    /// Called when the tour pages have loaded so we know how many pages we're dealing with.
    func setPageCount(to count: Int) {
        pageControl.numberOfPages = count
    }

    /// Called whenever the user scrolls between a page.
    func pageChanged(to number: Int) {
        pageControl.currentPage = number
    }
}
