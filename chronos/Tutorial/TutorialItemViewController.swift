//
//  TutorialItemViewController.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
import UIKit

class TutorialItemViewController: UIViewController, Storyboarded {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var heading: UILabel!
    @IBOutlet var body: UITextView!

    var item: TutorialItem?

    /// Load the appropriate tour item into our UI.
    override func viewDidLoad() {
        super.viewDidLoad()

        guard  let item = item else {
            fatalError("Attempted to create a TourItemViewController with no tour item.")
        }

        //imageView.image = UIImage(bundleName: item.image)//buggy
        heading.text = item.title
        body.text = item.text

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        //imageView.layer.borderColor = UIColor(bundleName: "Secondary").cgColor
        //imageView.layer.borderWidth = 1

        // force the content to go edge to edge
        body.textContainerInset = .zero
        body.textContainer.lineFragmentPadding = 0
    }

    // the text views like to start life scrolled to the end; force them not to do that
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        body.setContentOffset(.zero, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // The text is short enough that this won't be needed most of the time, but there's no harm flashing the indicators if it's needed.
        body.flashScrollIndicators()
    }
}
