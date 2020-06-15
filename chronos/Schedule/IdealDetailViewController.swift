//
//  IdealDetailViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class IdealDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var idealSchedule : IdealSchedule!
    var index : Int = 0
    var idealBlocks : Array<Block> = []
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup using passed idealSchedule
        idealBlocks = idealSchedule.blocks
        self.navigationItem.title = idealSchedule.name
        
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        //Add notification to update after dismiss
        NotificationCenter.default.addObserver(self, selector: #selector(IdealDetailViewController.reload), name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        reload()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdealBlockCell", for: indexPath) as! IdealBlockTableViewCell
        cell.titleLabel.text = idealBlocks[indexPath.section].name
        
        var hourNum : String = "\(idealBlocks[indexPath.section].time)"
        if idealBlocks[indexPath.section].time < 10{
            hourNum = "0" + hourNum
        }
        let minuteNum : String = "00"
        cell.timeLabel.text = "\(hourNum):\(minuteNum)"
        cell.durationLabel.text = "\(idealBlocks[indexPath.section].duration) min."
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    @objc func reload(){
        if let retrievedIdealSchedule = try?Data(contentsOf: URLs.idealSchedules){
            let decodedSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedIdealSchedule)
            idealSchedule = decodedSchedules[index]
        }
        idealBlocks = idealSchedule.blocks
        tableView.reloadData()
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToForm"{
            let destination = segue.destination as! AddBlockViewController
            destination.index = self.index
            destination.idealSchedule = self.idealSchedule
        }
     }
     
    
}