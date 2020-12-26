//
//  HomeViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/23/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit
import UserNotifications

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var clockLabel: UILabel!
    //Current Block
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startEndButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    var current_schedule : GeneratedSchedule = GeneratedSchedule.empty
    
    var timer = Timer()
    var currentTime = Time()
    
    
    //MARK: VIEW LOAD FUNCS
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize clock and currentTime
        startClock()
        
        //load saved schedule, if exists
        //REMINDER: remove schedule from memory if schedules date is not current date
        if let retrievedSchedule = try?Data(contentsOf: URLs.currentSchedule){
            current_schedule = try!propertyListDecoder.decode(GeneratedSchedule.self, from: retrievedSchedule)
        }
        
        
        //set current_schedule
        blockTableView.delegate = self
        blockTableView.dataSource = self
        
        //notification update
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.loadSchedule), name: NSNotification.Name(rawValue: "ScheduleSelected"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UPDATE THE ON SCREEN CLOCK
        startClock()
        //UPDATE THE VIEWS ACCORDING TO THE TIME
        updateUIState()
        //OTHER STUFF THAT NEEDS TO BE DYNAMICALLY CHANGED ON VIEW ENTRY
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //CONTROLS NAV ON VIEW APPEAR COMPLETION
        //CALL SEGUE TO POP-UP IF CURRENT-SCHEDULE IS GENERATED.EMPTY
    }
    
    //MARK: SETUP FUNCS
    @objc func loadSchedule(){
        
        //load schedule UI
        let retrievedSchedule = try!Data(contentsOf: URLs.currentSchedule)
        self.current_schedule = try!propertyListDecoder.decode(GeneratedSchedule.self, from: retrievedSchedule)
        updateSchedule()
        blockTableView.reloadData()
        
        //request notifications auth
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error:", error)
            }
            if !granted{
                //Alert explaining why notifications are necessary
                let alert = UIAlertController(title: "Oh no!", message: "Notifications are necessary to remind you of completed blocks! Please consider enabling these in settings.",  preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss" , style: UIAlertAction.Style.default, handler: { _ in
                    //some action to control change in preferences
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        //Begin notif cycle
        startNextBlock()
    }
    func startClock(){
        self.currentTime.getCurrentTime()
        clockLabel.text = self.currentTime.timeText()
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector:#selector(self.updateTimes) , userInfo: nil, repeats: true)
    }
    
    
    //MARK: MAIN FUNCS
    @objc func updateTimes(){
        //called every 1 second by timer, updates in-app time
        self.currentTime.getCurrentTime()
        clockLabel.text = self.currentTime.timeText()
        
        //Update time left label unless time is up
        let currentBlock = self.current_schedule.nextBlock()
        guard currentBlock != Block.empty else {return}
        guard currentBlock.status != "expired" else{return}
        //if time completes then change block status and call updateUIState
        if currentBlock.status == "didStart" && currentBlock.endTime()==currentTime{
            self.current_schedule.changeStatus(block: currentBlock, status: "expired")
            self.current_schedule.save()
        }
        updateUIState()
    }
    
    func startNextBlock(){
        let nextBlock = self.current_schedule.nextBlock()
        let timeDiff = currentTime.timeUntil(otherTime: nextBlock.time).toMinutes()
       
        //Ensure that block should be "started"
        guard nextBlock != Block.empty  else {
            //condition fails if schedule reaches end
            //handle here
            //alert user that schedule is completed
            updateUIState()
            return
        }
        if nextBlock.status == "missed rigid task" || nextBlock.status == "missed non-rigid task" {
            updateUIState()
            return
        }
        print(nextBlock.status)
        assert(nextBlock.status == "notStarted", "Block has been started")
        if timeDiff < 0{
            //alert that user is behind schedule
            showAlert(title: "Hmm..", text: "It seems you are a bit behind schedule. Don't worry, just start the next block when you are ready!", actionlabel: "Dismiss")
        }
        else if timeDiff == 0
        {
            showAlert(title: "Wow!", text: "It seems you are right on time for your next block! You can start now if you are ready.", actionlabel: "Dismiss")
        }
        else{
            //alert when schedule starts = "We'll notify you when to start this schedule, or you can start now and we can add the extra time in"
            showAlert(title: "Hey", text: "It seems you have some time before the next block starts. You can start now, or we can notify you when it's time to begin!", actionlabel: "Dismiss")
            //schedule notification for block start
            nextBlock.scheduleStartNotif(timeUntil: Time(minutes: timeDiff))
        }
        //CHANGES FIRST NON-COMPLETE/NOTSTARTED BLOCK TO WILLSTART
        self.current_schedule.changeStatus(block: nextBlock, status: "willStart")
        self.current_schedule.save()
        blockTableView.reloadData()
        updateUIState()
    }
    
    func updateUIState(){
        //Changes UI Based on Status of first non-complete block
        let currentBlock = current_schedule.nextBlock()
        containerView.isHidden = false
        nameLabel.text = "Current Task:  \(currentBlock.name)"
        if currentBlock.status == "notStarted"{
            self.current_schedule.changeStatus(block: currentBlock, status: "willStart")
            self.current_schedule.save()
            blockTableView.reloadData()
        }
        //WillStart
        if currentBlock.status == "willStart" {
            startEndButton.setTitle("Start", for: .normal)
            startTimeLabel.text = "Start Time:  \(currentBlock.time.timeText())"
            var timeUntilStart = "0 min"
            var timeDiff = currentTime.timeUntil(otherTime: currentBlock.time)
            if timeDiff.toMinutes() > 0{
                timeUntilStart = timeDiff.durationText()
            }
            else if timeDiff.toMinutes() < 0{
                timeDiff = currentBlock.time.timeUntil(otherTime: currentTime)
                timeUntilStart = timeDiff.durationText() + " ago"
            }
            timeLeftLabel.text = "Time Until Start:  \(timeUntilStart)"
        }
        //DidStart (In progress) - Show complete UI - Temp
        //TimeExpired - Show complete UI
        else if currentBlock.status == "expired" || currentBlock.status == "didStart"{
            startEndButton.setTitle("End", for: .normal)
            let endTime = currentBlock.endTime()
            startTimeLabel.text = "End Time:  \(endTime.timeText())"
            var timeUntilEnd = "0 min"
            let timeDiff = currentTime.timeUntil(otherTime: endTime)
            if timeDiff.toMinutes() > 0{
                timeUntilEnd = timeDiff.durationText()
            }
            timeLeftLabel.text = "Time Until End:  \(timeUntilEnd)"
        }
        //EMPTY
        else if currentBlock.status == "nil" || currentBlock.status == "missed rigid task"{
            containerView.isHidden = true
            print("Current Block is empty")
        }
        else{
            print("Unexpected Status in updateUIState", currentBlock.status)
        }
    }
    
    @IBAction func startEnd(_ sender: UIButton) {
        //starts timer or completes timer for current block
        //called by button on HomeViewController UI
        let buttonTitle = sender.title(for: .normal)
        let currentBlock = current_schedule.nextBlock()
        guard currentBlock != Block.empty else {return}
        if buttonTitle == "Start"{
            //setup here for start of block
            self.startEndButton.setTitle("End", for: .normal)
            //set start time of block to current time
            self.current_schedule.changeTime(block: currentBlock, time: currentTime)
            //adjust rest of start time of the rest of the blocks if needed
            //change status to "didStart"
            self.current_schedule.changeStatus(block: currentBlock, status: "didStart")
            self.current_schedule.save()
            //Make call to updateUIState
            updateUIState()
            blockTableView.reloadData()
            //handle notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["startNotif"])
            //end notif uses duration of block as the timer
            currentBlock.scheduleEndNotif()
            return
        }
        else if buttonTitle == "End"{
            //check time
            //show warning if user is ending early
            //if they confirm, show early end UI
            //if ending on time, show proper end UI
            self.startEndButton.setTitle("Start", for: .normal)
            //set duration of block to time spent working
            self.current_schedule.changeDuration(block: currentBlock, duration: currentBlock.time.timeUntil(otherTime: currentTime) )
            //Make call to updateUIState
            updateUIState()
            blockTableView.reloadData()
            //save time spent, completed duration, stats here
            //change block status to completed - temporary
            self.current_schedule.changeStatus(block: currentBlock, status: "completed")
            current_schedule.save()
            startNextBlock()
            //handle notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["endNotif"])
            return
        }
    }
    
    func changeBlockStatus(){
        //NOT YET IMPLEMENTED - CALLS UI TO UPDATE BLOCK STATUS
    }
    //MARK: Algorithm Implementation
    var schedule: Array<DoubleBlock> = []
    func updateSchedule(){
        //UPDATES the view and adjust blocks etc. based on time
        //Called when a block is completed/time expired and when view appears
        var doubleTime: Double
        var doubleDuration: Double
        var currentDoubleTime: Double
        schedule = []
        for block in current_schedule.blocks {
            doubleTime = Double(block.time.toMinutes()/60) + (Double(block.time.toMinutes()%60)/60)
            doubleDuration = Double(block.duration.toMinutes()/60) + (Double(block.duration.toMinutes()%60)/60)
            doubleTime = doubleTime.truncate()
            doubleDuration = doubleDuration.truncate()
            schedule.append(DoubleBlock(time: doubleTime, duration: doubleDuration, name: block.name, rigid: block.rigid, priority: Double(block.priority), status: block.status))
        }
        currentDoubleTime = Double(currentTime.toMinutes()/60) + ((Double(currentTime.toMinutes()%60))/60)
        calcTime(currentTime: currentDoubleTime)
        var windows = [Window(start: currentDoubleTime, end: 24)]
        
        for index in schedule.indices {
          if schedule[index].status != "completed" && schedule[index].rigid {
            let rigid_block = schedule[index]

            var missed = true

            for window_idx in windows.indices{
              if(blockInWindow(block: rigid_block, window: windows[window_idx])){
                // remove the window that already existed, replace it with new windows
                let new_later_part_window = Window(start: rigid_block.time + rigid_block.duration, end: windows[window_idx].end)
                windows.insert(new_later_part_window, at: window_idx+1)
                windows[window_idx].end = rigid_block.time
                schedule[index].status = "notStarted"

                missed = false
                break
              }
            }

            if(missed){
              print("SAD, you misseed a rigid task. here is the task:")
              print(schedule[index].name)
              showAlert(title: "Sad", text: "It seems you have misseed a rigid task. here is the task: \(schedule[index].name)", actionlabel: "Dismiss")
              schedule[index].status = "missed rigid task"
            }

          }
        }
        // non_rigid_tasks.sort(by: getPriority)
        // sort non-rigid tasks by priority...

        schedule.sort(by: >)
        
        for index in schedule.indices {
          if schedule[index].status != "completed" && !schedule[index].rigid {

            var scheduled = false

            for window_idx in windows.indices{
              if(blockFitsInWindow(block: schedule[index], window: windows[window_idx])){
                // remove the window that already existed, replace it with new windows
                // update start time
                schedule[index].time = windows[window_idx].start
                schedule[index].status = "notStarted"
                windows[window_idx].start += schedule[index].duration

                scheduled = true
                break
              }
            }
            if(!scheduled){
                print("SAD, wasn't able to fit a task into your day. here is the task:")
                print(schedule[index].name)
                schedule[index].status = "missed non-rigid task"
                
            }

          }
        }

        print(schedule)
        current_schedule.empty()
        var scheduleBlock: Block
        var totalTime: Double
        var totalDuration: Double
        for doubleBlock in schedule {
            totalTime = doubleBlock.time*60
            //if(doubleBlock.time.truncatingRemainder(dividingBy: 1) != 0){totalTime+=1}
            totalDuration = doubleBlock.duration*60
            //if(doubleBlock.duration.truncatingRemainder(dividingBy: 1) != 0){totalDuration-=1}
            scheduleBlock = Block(time: Time(minute: Int(totalTime.truncatingRemainder(dividingBy: 60)), hour: Int(totalTime/60)), duration: Time(minute: Int(totalDuration.truncatingRemainder(dividingBy: 60)), hour: Int(totalDuration/60)), completionDuration: Time.empty, name: doubleBlock.name, rigid: doubleBlock.rigid, priority: Int(doubleBlock.priority), status: doubleBlock.status)
            current_schedule.blocks.append(scheduleBlock)
        
        }
        current_schedule.blocks = current_schedule.blocks.sorted(by: {$0.time.toMinutes()<$1.time.toMinutes()})
        current_schedule.save()
    }
    func calcTime(currentTime: Double) {
      // print(schedule) //  prints the original schedule for comparison
      // calculates the total amount of time left to spend on activies that are not rigid
      var timeLeft = 24.0 - currentTime
        let tempWindow = Window(start: currentTime, end: 24)
      for index in schedule.indices{
        if schedule[index].status != "completed" && schedule[index].rigid == true && blockInWindow(block: schedule[index], window: tempWindow){
          timeLeft = timeLeft - schedule[index].duration
        }
      }

      var totalTime = 0.0 // original sum of the non-rigid activity times
      var totalPriority = 0.0 // sum of the non-rigid priority values
      // var indexOfFirst = 100 // index of the first "yet to be done" element of schedule
      var counter = 0.0 //  # of "yet to be done" non-rigid activities
      for index in schedule.indices{
        if schedule[index].status != "completed" && schedule[index].rigid == false{
          totalTime = totalTime + schedule[index].duration // sums the original durations
          totalPriority = totalPriority + schedule[index].priority
          counter = counter + 1.0
        }
      }
        var maxDuration: Double
      for index in schedule.indices{
        if schedule[index].status != "completed" && schedule[index].rigid == false{
            maxDuration=schedule[index].duration
           schedule[index].duration = (schedule[index].duration * timeLeft / totalTime) * (schedule[index].priority * counter / totalPriority) // caculates the new durations
            if maxDuration<schedule[index].duration{schedule[index].duration=maxDuration}
           schedule[index].duration = schedule[index].duration.truncate()
        }
      }
    }
    func blockInWindow(block:DoubleBlock , window: Window) -> Bool{
      return block.time >= window.start && block.time + block.duration <= window.end
    }
    //MARK: WEIRD BUG FIX ATTEMPT
    func blockFitsInWindow(block:DoubleBlock , window: Window) -> Bool{
        var newWindow = window
        newWindow.end+=0.016
        return block.duration <= newWindow.end - newWindow.start
    }
    func getPriority(block : DoubleBlock) -> Double{
      return block.priority;
    }
  
    func showAlert(title: String , text: String, actionlabel: String) {
        let alert = UIAlertController(title: title, message: text,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: actionlabel , style: UIAlertAction.Style.default, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return current_schedule.blocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = blockTableView.dequeueReusableCell(withIdentifier: "BlockCell", for: indexPath) as! BlockTableViewCell
        //Data
        let repr_block = current_schedule.blocks[indexPath.row]
        cell.titleLabel.text = repr_block.name
        cell.timeLabel.text = repr_block.time.timeText()
        cell.durationLabel.text = repr_block.duration.durationText()
        
        //IMPLEMENT SOME LOGIC HERE TO DIFFERENTIATE CELLS BY STATUS
        if repr_block.status == "notStarted"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.tophalf.fill")
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        else if repr_block.status == "willStart"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.tophalf.fill")
            cell.layer.borderColor = UIColor.systemOrange.cgColor
        }
        else if repr_block.status == "didStart"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass")
            cell.layer.borderColor = UIColor.green.cgColor
        }
        else if repr_block.status == "completed"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.bottomhalf.fill")
            cell.layer.borderColor = UIColor.blue.cgColor
        }
        else if repr_block.status == "missed rigid task"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.bottomhalf.fill")
            cell.layer.borderColor = UIColor.red.cgColor
        }
        
        //Minor UI Enhancements
        cell.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 4.0
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
// MARK: - Algorithm Extensions
extension Double
{
    func truncate()-> Double
    {
        return Double(floor(pow(10.0, Double(2)) * self)/pow(10.0, Double(2)))
    }
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
