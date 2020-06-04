//
//  constants.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation

struct block:Codable{
    //time and duration in minutes
    var time : Int
    var duration : Int
    
    var name : String
    var rigid : Bool
    
    //status = "completed", "failed", "postponed", "not attempted" etc.
    var status : String
}
