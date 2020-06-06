//
//  TutorialItem.swift
//  chronos
//
//  Created by Paul Muser on 6/6/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
import UIKit

/// Stores a single page of the app tour loaded from JSON.
struct TutorialItem: Decodable {
    let image: String
    let title: String
    let text: String
}
