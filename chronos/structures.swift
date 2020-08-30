//
//  constants.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import Foundation
import UserNotifications
let propertyListEncoder = PropertyListEncoder()
let propertyListDecoder = PropertyListDecoder()

//MARK:- EVENT BLOCK
struct Block : Codable, Equatable{
    //time and duration in minutes
    var time : Time
    var duration : Time
    var completionDuration : Time
    
    var name : String
    var rigid : Bool
    var priority : Int
    
    //status = "notStarted","willStart","didStart","expired","completed","nil"
    var status : String
    
    //static blocks
    static let empty = Block(time: Time.empty, duration: Time.empty, completionDuration: Time.empty, name: "", rigid: false, priority: -1, status: "nil")
    
    func endTime() -> Time{
        return self.time.add(otherTime: self.duration)
    }
    
    func scheduleStartNotif(timeUntil: Time){
        /* takes in a Time struct representing the time until
            the block should begin, registers a local notification
            to remind the user when to begin block
        */
        let content = UNMutableNotificationContent()
        content.title = "Start"
        content.subtitle = "It is time to begin '\(self.name)'"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(timeUntil.toMinutes())*60)-5, repeats: false)
        let request = UNNotificationRequest(identifier: "startNotif", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("Scheduled a Start Notification")
    }
    
    func scheduleEndNotif(){
        /* takes in a Time struct representing the time until
            the block should end, registers a local notification
            to remind the user when the block is completed
        */
        
        let content = UNMutableNotificationContent()
        content.title = "Time's Up"
        content.subtitle = "Time is up for '\(self.name)'."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(self.duration.toMinutes())*60), repeats: false)
        let request = UNNotificationRequest(identifier: "endNotif", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("Scheduled an End Notification")
    }
    
    static func == (lhs: Block, rhs: Block) -> Bool {
        return lhs.name == rhs.name &&
            lhs.rigid == rhs.rigid &&
            lhs.priority == rhs.priority &&
            lhs.status == rhs.status
    }
}



//MARK:- IDEAL SCHEDULE
struct IdealSchedule : Codable{
    var name : String
    var blocks : Array<Block>
    
    //[Monday,Tuesday] etc.
    var days : Array<String>
    var targetDate : Date
    var daysUntilDeadline : Int
    func delete(indexPath: IndexPath){
        var decodedSchedules : Array<IdealSchedule> = []
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            decodedSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
            decodedSchedules.remove(at: indexPath.row)
    }
    }
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
        //reminder: pass ideal schedule with the gen sched - implement later
        var sched = GeneratedSchedule(name: self.name, blocks: self.blocks, date: Date(), accuracy: 0)
        for block in sched.blocks{
            sched.changeStatus(block: block, status: "notStarted")
        }
        return sched
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
    static let empty = GeneratedSchedule(name: "Blank", blocks: [], date: Date(), accuracy: -1)
    
    func save(){
        //function to save current progress and schedule for the current day
        let encodedSchedule = try?propertyListEncoder.encode(self)
        try?encodedSchedule?.write(to: URLs.currentSchedule)
        //print("current schedule saved")
    }
    func log(){
        //function adds the generatedSchedule to Array<generatedSchedule>
        //saves the array for analytics purposes
    }
    func nextBlock() -> Block{
        //returns the first block in the list of blocks in which status is not "complete"
        for block in self.blocks{
            if block.status != "completed"{
                return block
            }
        }
        return Block.empty
    }
    mutating func changeStatus(block: Block, status: String){
        //changes status of block
        let replaceIndex = self.blocks.firstIndex(of: block)
        self.blocks[replaceIndex!].status = status
    }
    mutating func changeTime(block: Block, time: Time){
        //changes status of block
        let replaceIndex = self.blocks.firstIndex(of: block)
        self.blocks[replaceIndex!].time = time
    }
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
struct Time : Codable, Equatable{
    var minute: Int = 0
    var hour: Int = 0
    
    init(minute: Int, hour: Int){
        self.minute = minute
        self.hour = hour
    }
    
    init(minutes: Int) {
        self.minute = minutes%60
        self.hour = minutes/60
    }
    
    init(){
        var time = Time(minutes: 0)
        time.getCurrentTime()
        self.minute = time.minute
        self.hour = time.hour
    }
    
    static let empty = Time(minute: -1, hour: -1)
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.minute == rhs.minute && lhs.hour == rhs.hour
    }
    
    mutating func getCurrentTime(){
        //updates minute and hour values to match those of the current time
        let date = Date()
        let calendar = Calendar.current
        self.minute = calendar.component(.minute, from: date)
        self.hour = calendar.component(.hour, from: date)
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
    func timeUntil(otherTime: Time) -> Time{
        //computes the time difference between self and another Time
        return Time(minutes: otherTime.toMinutes() - self.toMinutes())
    }
    func add(otherTime: Time) -> Time{
        //returns a new Time from adding a time obj to self
        var new_hour = self.hour + otherTime.hour
        var new_minute = self.minute + otherTime.minute
        new_hour += new_minute/60
        new_minute %= 60
        return Time(minute: new_minute, hour: new_hour)
    }
    func toMinutes() -> Int{
        return self.minute + 60*self.hour
    }
}


//MARK:- DATA DIRECTORIES
struct URLs{
    static let idealSchedules = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("idealSchedules").appendingPathExtension("plist")
    
    static let currentSchedule = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("currentSchedule").appendingPathExtension("plist")
    
    static let log = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log").appendingPathExtension("plist")
    
    static let user = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("user").appendingPathExtension("plist")
}

