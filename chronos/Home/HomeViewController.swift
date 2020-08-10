//
//  HomeViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/23/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

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
        startClock()
        updateUIState()
        //UPDATE THE ON SCREEN CLOCK
        //UPDATE THE VIEWS ACCORDING TO THE TIME
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
        guard nextBlock != Block.empty else {
            //condition fails if schedule reaches end
            //handle here
            //alert user that schedule is completed
            updateUIState()
            return
        }
        assert(nextBlock.status == "notStarted", "Block has been started")
        if timeDiff < 0{
            //alert that user is behind schedule
        }
        else{
            //alert when schedule starts = "We'll notify you when to start this schedule, or you can start now and we can add the extra time in"
            //schedule notification for block start
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
        //WillStart
        if currentBlock.status == "willStart"{
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
        else if currentBlock.status == "nil"{
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
            //schedule notification for block end
            //
            return
        }
        else if buttonTitle == "End"{
            //procedure when block is ended early
            self.startEndButton.setTitle("Start", for: .normal)
            //save time spent, completed duration, stats here
            //change block status to completed - temporary
            self.current_schedule.changeStatus(block: currentBlock, status: "completed")
            current_schedule.save()
            startNextBlock()
            return
        }
        
    }
    
    func changeBlockStatus(){
        //NOT YET IMPLEMENTED - CALLS UI TO UPDATE BLOCK STATUS
    }
    
    func updateSchedule(){
        //UPDATES the view and adjust blocks etc. based on time
        //Called when a block is completed/time expired and when view appears
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
            cell.layer.borderColor = UIColor.yellow.cgColor
        }
        else if repr_block.status == "didStart"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass")
            cell.layer.borderColor = UIColor.green.cgColor
        }
        else if repr_block.status == "completed"{
            cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.bottomhalf.fill")
            cell.layer.borderColor = UIColor.blue.cgColor
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
