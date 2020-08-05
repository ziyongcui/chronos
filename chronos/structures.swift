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
    var time : Time
    var duration : Time
    var completionDuration : Time
    
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
    var targetDate : Date
    var daysUntilDeadline : Int
    
    func save(){
        var decodedSchedules : Array<IdealSchedule> = []
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            decodedSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
            //replaces(updates) existing schedule of the same name or appends if no schedule of the same name exists
            var didReplace : Bool = false
            for i in 0...(decodedSchedules.count-1){
                if decodedSchedules[i].name == self.name{
                    decodedSchedules[i] = self
                    didReplace = true
                }
            }
            if !didReplace{
                decodedSchedules.append(self)
            }
        }
        else{
            //a list of decodedSchedules does not exist yet
            decodedSchedules.append(self)
        }
        let encodedSchedules = try?propertyListEncoder.encode(decodedSchedules)
        try?encodedSchedules?.write(to: URLs.idealSchedules)
    }
    func generateSchedule() -> GeneratedSchedule{
        //input includes data from analysis of previous data
        return GeneratedSchedule(name: self.name, blocks: self.blocks, date: Date(), accuracy: 0)
    }
}

//MARK:- GENERATED SCHEDULE
struct GeneratedSchedule : Codable{
    var name : String
    var blocks: Array<Block>
    
    //the date for which this schedule applies to
    var date : Date
    
    //user modification to schedule e.g adding,removing blocks
    var modifications : [String:Array<Block>] = [:]
    
    //accuracy could also be double or float - for analysis
    var accuracy : Int
    
    func save(){
        //function to save current progress and schedule for the current day
        let encodedSchedule = try?propertyListEncoder.encode(self)
        try?encodedSchedule?.write(to: URLs.currentSchedule)
        print("current schedule saved")
    }
    func log(){
        //function adds the generatedSchedule to Array<generatedSchedule>
        //saves the array for analytics purposes
    }
    static let empty = GeneratedSchedule(name: "Blank", blocks: [], date: Date(), accuracy: -1)
}

//MARK:- USER DATA
struct User : Codable{
    //lastLogin is a date, could be represented by an int or even a dateObj
    var lastLogin : String
    func save(){
        //save user data
        let encodedUserInfo = try!propertyListEncoder.encode(self)
        try!encodedUserInfo.write(to: URLs.user, options: .noFileProtection)
    }
}

//MARK:- TIME
struct Time : Codable{
    var minute: Int = 0
    var hour: Int = 0
    
    static let empty = Time(minute: -1, hour: -1)
    func getCurrentTime(){
        //updates minute and hour values to match those of the current time
    }
    func timeText() -> String{
        //return a time formatted string
        var minuteString = "\(self.minute)"
        if self.minute<10{
            minuteString = "0\(self.minute)"
        }
        if self.hour > 12{
            return "\(self.hour-12):\(minuteString) P.M"
        }
        else if self.hour == 12{
            return "\(self.hour):\(minuteString) P.M"
        }
        else{
            return "\(self.hour):\(minuteString) A.M"
        }
            
    }
    func durationText() -> String{
        //return a duration formatted string
        var durationString = ""
        if self.hour > 0{
            durationString += "\(self.hour) hr"
        }
        if self.minute > 0{
            durationString += " \(self.minute) min"
        }
        return durationString
    }
    func difference(otherTime: Time) -> Time{
        //computes the time difference between self and another Time
        //NOT YET IMPLEMENTED
        return Time()
    }
    func add(otherTime: Time) -> Time{
        //returns a new Time from adding a time obj to self
        var new_hour = self.hour + otherTime.hour
        var new_minute = self.minute + otherTime.minute
        new_hour += new_minute/60
        new_minute %= 60
        return Time(minute: new_minute, hour: new_hour)
    }
}


//MARK:- DATA DIRECTORIES
struct URLs{
    static let idealSchedules = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("idealSchedules").appendingPathExtension("plist")
    
    static let currentSchedule = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("currentSchedule").appendingPathExtension("plist")
    
    static let log = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log").appendingPathExtension("plist")
    
    static let user = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("user").appendingPathExtension("plist")
}

