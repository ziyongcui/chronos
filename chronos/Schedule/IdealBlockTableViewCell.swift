//
//  IdealBlockTableViewCell.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/11/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class IdealBlockTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
