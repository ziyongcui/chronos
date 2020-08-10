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
        print("View Appeared")
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
        var blockWithStates : Array<Block> = []
        for block in current_schedule.blocks{
            var newBlock = block
            newBlock.status = "notStarted"
            blockWithStates.append(newBlock)
        }
        current_schedule.blocks = blockWithStates
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
        self.currentTime = Time().getCurrentTime()
        clockLabel.text = self.currentTime.timeText()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateClock) , userInfo: nil, repeats: true)
    }
    
    
    //MARK: MAIN FUNCS
    @objc func updateClock(){
        self.currentTime = Time().getCurrentTime()
        clockLabel.text = self.currentTime.timeText()
    }
    
    func startNextBlock(){
        var nextBlock = self.current_schedule.nextBlock()
        let timeDiff = currentTime.timeUntil(otherTime: nextBlock.time).toMinutes()
        if timeDiff < 0{
            //adjust time for all blocks
            //alert that schedule starts now
            //change status to "InProgress"
            //schedule notification for block end
        }
        else{
            //alert when schedule starts = "We'll notify you when to start this schedule, or you can start now and we can add the extra time in"
            //schedule notification for block start
        }
    }
    
    func changeBlockStatus(){
        
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
        cell.statusIndicatorImage.image = UIImage(systemName: "hourglass.tophalf.fill")
        
        //Minor UI Enhancements
        cell.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        cell.layer.borderColor = UIColor.clear.cgColor
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
