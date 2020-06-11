//
//  constants.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
let propertyListEncoder = PropertyListEncoder()
let propertyListDecoder = PropertyListDecoder()

//MARK:- EVENT BLOCK
struct Block : Codable{
    //time and duration in minutes
    var time : Int
    var completedTime: Int //not sure if we need this
    var duration : Int
    var completionDuration : Int
    
    var name : String
    var rigid : Bool
    var priority : Int
    
    //status = "completed", "failed", "postponed", "not attempted" etc.
    var status : String
}



//MARK:- IDEAL SCHEDULE
struct IdealSchedule : Codable{
    var name : String
    var blocks : Array<Block>
    
    //[Monday,Tuesday] etc.
    var days : Array<String>
    var targetDate : String
    var daysUntilDeadline : Int
    
    func save(){
        //function to replace (or add) into array of ideal schedules
        //saves array of ideal schedules
    }
    func generateSchedule(){
        //input includes data from analysis of previous data
        //output GeneratedSchedule
    }
}

//MARK:- GENERATED SCHEDULE
struct GeneratedSchedule : Codable{
    var name : String
    var blocks: Array<Block>
    
    //the date for which this schedule applies to
    var date : String
    
    //user modification to schedule e.g adding,removing blocks
    var modifications : [String:Array<Block>]
    
    //accuracy could also be double or float - for analysis
    var accuracy : Int
    
    func save(){
        //function to save current progress and schedule for the current day
    }
    func log(){
        //function adds the generatedSchedule to Array<gneratedSchedule>
        //saves the array for analytics purposes
    }
}

//MARK:- USER DATA
struct User : Codable{
    //lastLogin is a date, could be represented by an int
    var lastLogin : String
    func save(){
        //save user data
        let encodedUserInfo = try!propertyListEncoder.encode(self)
        try!encodedUserInfo.write(to: URLs.user, options: .noFileProtection)
    }
}



//MARK:- DATA DIRECTORIES
struct URLs{
    static let idealSchedules = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("idealSchedules").appendingPathExtension("plist")
    
    static let currentSchedule = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("currentSchedule").appendingPathExtension("plist")
    
    static let log = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log").appendingPathExtension("plist")
    
    static let user = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("user").appendingPathExtension("plist")
}

