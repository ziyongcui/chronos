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
    var current_schedule : GeneratedSchedule = GeneratedSchedule.empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //ATTEMPT TO LOAD THE GENERATED SCHEDULE FOR THE DAY. IF NONE EXISTS
        //  SET CURRENT_SCHEDULE TO NIL AND CALL SEGUE IN VIEWDIDAPPEAR
        
        //set current_schedule
        blockTableView.delegate = self
        blockTableView.dataSource = self
        
        //notification update
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.loadSchedule), name: NSNotification.Name(rawValue: "ScheduleSelected"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //CALL SEGUE TO POP-UP IF CURRENT-SCHEDULE IS GENERATED.EMPTY
        //UPDATE THE ON SCREEN CLOCK
        //UPDATE THE VIEWS ACCORDING TO THE TIME
        //OTHER STUFF THAT NEEDS TO BE DYNAMICALLY CHANGED ON VIEW ENTRY
    }
    
    //MARK: SETUP FUNCS
    @objc func loadSchedule(){
        let retrievedSchedule = try!Data(contentsOf: URLs.currentSchedule)
        self.current_schedule = try!propertyListDecoder.decode(GeneratedSchedule.self, from: retrievedSchedule)
        blockTableView.reloadData()
        //save logic here as well as basic setups with notifications and timers
        //function only for loading the views
    }
    
    func updateSchedule(){
        //UPDATES the view and adjust blocks etc. based on time
        //Called when a block is completed/time expired and when view appears
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
