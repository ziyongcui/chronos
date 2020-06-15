//
//  IdealScheduleViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class IdealScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var idealSchedules : Array<IdealSchedule> = []
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load blocks from (sample) save
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            idealSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
        }
        else{
            //temporary block
            let tempSchedule = IdealSchedule(name: "testSchedule", blocks: [], days: ["Monday","Friday"], targetDate: "01-04", daysUntilDeadline: 0)
            idealSchedules.append(tempSchedule)
        }
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            idealSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
        }
        tableView.reloadData()
        print("viewWillAppear")
    }
    
    //MARK: - TABLE VIEW CONFIGURATION
    func numberOfSections(in tableView: UITableView) -> Int {
        return idealSchedules.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdealScheduleCell", for: indexPath) as! IdealScheduleTableViewCell
        cell.titleLabel.text = idealSchedules[indexPath.section].name
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
