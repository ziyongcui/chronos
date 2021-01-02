//
//  GeneratedDetailViewController.swift
//  chronos
//
//  Created by Paul Development on 12/29/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class GeneratedDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var generatedSchedule : GeneratedSchedule!
    var idealBlocks : Array<Block> = []
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup using passed idealSchedule
        idealBlocks = generatedSchedule.blocks
        self.navigationItem.title = generatedSchedule.name
        
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        //Add notification to update after dismiss
        NotificationCenter.default.addObserver(self, selector: #selector(GeneratedDetailViewController.reload), name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
    }
    
    //MARK: - TABLE VIEW CONFIGURATION
    func numberOfSections(in tableView: UITableView) -> Int {
        return idealBlocks.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneratedBlockCell", for: indexPath) as! GeneratedBlockTableViewCell
        cell.titleLabel.text = idealBlocks[indexPath.section].name
        cell.timeLabel.text = idealBlocks[indexPath.section].time.timeText()
        cell.durationLabel.text = idealBlocks[indexPath.section].completionDuration.durationText()
        cell.layer.cornerRadius = 0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 3
        cell.selectionStyle = .none
        let repr_block = idealBlocks[indexPath.section]
        if repr_block.status == "notStarted"{
            
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        else if repr_block.status == "willStart"{
            
            cell.layer.borderColor = UIColor.systemOrange.cgColor
        }
        else if repr_block.status == "didStart"{
            
            cell.layer.borderColor = UIColor.green.cgColor
        }
        else if repr_block.status == "completed"{
           
            cell.layer.borderColor = UIColor.blue.cgColor
        }
        else if repr_block.status == "missed rigid task"{
      
            cell.layer.borderColor = UIColor.red.cgColor
        }
        
        return cell
    }
    // this method handles row deletion
    
    
    @objc func reload(){
        if let retrievedGeneratedSchedule = try?Data(contentsOf: URLs.finishedSchedules){
            let decodedSchedules = try!propertyListDecoder.decode(Array<GeneratedSchedule>.self, from: retrievedGeneratedSchedule)
            for schedule in decodedSchedules{
                if schedule.name == generatedSchedule.name{
                    generatedSchedule = schedule
                }
            }
        }
        idealBlocks = generatedSchedule.blocks
        tableView.reloadData()
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     
    
}
