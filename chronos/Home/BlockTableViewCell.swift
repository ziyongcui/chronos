//
//  BlockTableViewCell.swift
//  chronos
//
//  Created by Ronnoc Gnad on 7/21/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class BlockTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var statusIndicatorImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
