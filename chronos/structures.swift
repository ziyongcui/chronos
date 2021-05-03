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
var idealSchedules : Array<IdealSchedule> = []

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
        return self.time.add(otherTime: self.completionDuration)
    }
    
    /*
    func delete(indexPath: IndexPath){
            
        var decodedBlocks : Array<Block> = []
        if let retrievedBlocks = try?Data(contentsOf: URLs.currentSchedule){
            decodedBlocks = try!propertyListDecoder.decode(Array<Block>.self, from: retrievedBlocks)
            decodedBlocks.remove(at: indexPath.row)
            
            let encodedSchedules = try?propertyListEncoder.encode(decodedBlocks)
            try?encodedSchedules?.write(to: URLs.currentSchedule)
      }
    }
    */
    
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


struct DoubleBlock : Codable, Comparable{
    static func > (lhs: DoubleBlock, rhs: DoubleBlock) -> Bool {
      if lhs.priority > rhs.priority{
        return true
      }
      else{
        return false
      }
    }
    static func < (lhs: DoubleBlock, rhs: DoubleBlock) -> Bool {
      if lhs.priority < rhs.priority{
        return true
      }
      else{
        return false
      }
    }
    //time and duration in minutes
    var time : Double //c
    // var completedTime: Int //not sure if we need this
    var duration : Double // c
    // var completionDuration : Int
    //
    var priorDuration : Double
    var name : String
    var rigid : Bool
    var priority : Double
    //
    // //status = "completed", "failed", "postponed", "not attempted" etc.
    var status : String
}
 

//MARK:- IDEAL SCHEDULE
class IdealSchedule : Codable {
    
    var name : String
    var blocks : Array<Block>
    ///var days : Array<String>
    ///var targetDate : Date
    ///var daysUntilDeadline : Int
    var desc : String
    var attempts : Array<Schedule>
    
    /// Static Ideal Schedule - For Development Purposes
    static let EMPTY = IdealSchedule(name: "No Schedules Made!", desc : "You have not created any ideal schedules yet, go to the schedules tab to create new schedules and add blocks in them.")
    
    /// Initializes an empty ideal schedule - Used in  AddScheduleViewController
    ///     - Constructor adds the instantiated ideal schedule
    init(name: String, desc : String) {
        self.name = name
        self.blocks = []
        self.desc = desc
        // TODO: Add calculation for days until deadline
        self.attempts = []
    }
    
    /// Commented out for now - The idealSchedules header may be unnecessary
    /*
    static func save(idealSchedules: Array<IdealSchedule>) {
        let encodedSchedules = try?propertyListEncoder.encode(idealSchedules)
        try?encodedSchedules?.write(to: URLs.idealSchedules)
    }
    */
    
    static func save() {
        let encodedSchedules = try?propertyListEncoder.encode(idealSchedules)
        try?encodedSchedules?.write(to: URLs.idealSchedules)
    }
    
    /// Generates a Schedule based on the IdealSchedule
    func generateSchedule() -> Schedule {
        return Schedule(ideal: self)
    }
}

// MARK:- SCHEDULE (DAILY SCHEDULE)
class Schedule : Codable {

    /// The IdealSchedule that the Schedule is based on
    var ideal : IdealSchedule
    
    /// An identification method for a specific schedule - may not be needed
    /// Should be removed later to reduce code complexity
    var name : String
    
    /// An array of blocks representing the schedule
    /// These blocks may be modified depending on user interactions, adjustment alg, etc.
    var blocks : Array<Block>
    
    /// The date for which this schedule applies to
    var date : Date
    
    /// User modifications to schedule e.g adding,removing blocks - NOT YET IMPLEMENTED
    var modifications : [String:Array<Block>] = [:]
    
    /// accuracy could also be double or float - used for analysis
    var accuracy : Int
    
    /// static empty default schedule - used to load blank home screen
    ///     - Also used to check if valid schedule is active
    static let EMPTY = Schedule()
    
    /// Creates a schedule based on an ideal schedule
    init (ideal : IdealSchedule) {
        self.ideal = ideal
        self.blocks = ideal.blocks
        self.date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        self.name = "\(formatter1.string(from: self.date)) - \(self.ideal.name)"
        //Default value should be changed later
        accuracy = 0
        for block in self.blocks{
            changeStatus(block: block, status: "notStarted")
        }
    }
    
    private init () {
        self.ideal = IdealSchedule.EMPTY
        self.blocks = []
        self.date = Date()
        self.name = ""
        self.accuracy = 0
    }
    
    /// Saves the schedule into currentSchedule data directory
    func save(){
        let encodedSchedule = try?propertyListEncoder.encode(self)
        try?encodedSchedule?.write(to: URLs.currentSchedule)
        print("current schedule saved")
    }
    
    /// Saves the schedule for later analysis
    ///     - This is done by appending the schedule to an Array of attempted schedules
    ///     - Should be called upon completion of the schedule or if day restarts
    ///     - The schedule is stored in an attribute of IdealSchedule for the sake of reducing complexity.
    ///             - Each IdealSchedule contains a list of 'attempted' Schedules that can be used for analysis
    ///             - Prevents analysis of schedules that do not have IdealSchedules (deleted/removed by user)
    func log(){
        self.ideal.attempts.append(self)
        IdealSchedule.save()
    }
    /*
    func delete(indexPath: IndexPath){
        var decodedSchedules : Array<GeneratedSchedule> = []
        if let retrievedSchedules = try?Data(contentsOf: URLs.finishedSchedules){
            decodedSchedules = try!propertyListDecoder.decode(Array<GeneratedSchedule>.self, from: retrievedSchedules)
            decodedSchedules.remove(at: indexPath.row)
            let encodedSchedules = try?propertyListEncoder.encode(decodedSchedules)
            try?encodedSchedules?.write(to: URLs.finishedSchedules)
        }
    }
 */
    
    /// Removes all blocks in the schedule. - May not be needed.
    func empty(){
        self.blocks = []
    }
    func nextBlock() -> Block{
        //returns the first block in the list of blocks in which status is not "complete"
        for block in self.blocks{
            if block.status != "completed" && block.status != "missed rigid task" && block.status != "missed non-rigid task"{
                return block
            }
        }
        return Block.empty
    }
    func changeStatus(block: Block, status: String){
        //changes status of block
        let replaceIndex = self.blocks.firstIndex(of: block)
        self.blocks[replaceIndex!].status = status
    }
    func changeTime(block: Block, time: Time){
        //changes status of block
        let replaceIndex = self.blocks.firstIndex(of: block)
        self.blocks[replaceIndex!].time = time
    }
    func changeDuration(block: Block, duration: Time){
        //changes duration spent on block
        let replaceIndex = self.blocks.firstIndex(of: block)
        self.blocks[replaceIndex!].completionDuration = duration
    }
}

//MARK:- Window
struct Window {
    var start : Double
    var end : Double
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
            return "\(self.hour-12):\(minuteString) PM"
        }
        else if self.hour == 12{
            return "\(self.hour):\(minuteString) PM"
        }
        else{
            return "\(self.hour):\(minuteString) AM"
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

