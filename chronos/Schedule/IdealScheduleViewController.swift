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

    var selectedSchedule : IdealSchedule? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(IdealScheduleViewController.reload), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //Add notification to update after dismiss
        NotificationCenter.default.addObserver(self, selector: #selector(IdealScheduleViewController.reload), name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
        
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func reload(){
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            idealSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
        }
        tableView.reloadData()
    }
    
    //MARK: - TABLE VIEW CONFIGURATION
    
    //makes each item an individual section to utilize header spacing
    func numberOfSections(in tableView: UITableView) -> Int {
        return idealSchedules.count
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
    
    //Instantiate Reusable Cell for each of the user's ideal schedules
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdealScheduleCell", for: indexPath) as! IdealScheduleTableViewCell
        cell.titleLabel.text = idealSchedules[indexPath.section].name
        
        //some small UI enhancing
    
        cell.layer.cornerRadius = 0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        cell.selectionStyle = .none
        return cell
    }
    
    //code to run when cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSchedule = idealSchedules[indexPath.section]
        self.performSegue(withIdentifier: "IdealScheduleToDetail", sender: nil)
    }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //tableView.deleteRows(at: [indexPath], with: .fade)
            idealSchedules.remove(at: indexPath.section)
            IdealSchedule.save()
            print(idealSchedules)
            tableView.reloadData()
            //tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the selected schedule to the IdealDetailViewController
        if segue.identifier == "IdealScheduleToDetail"{
            guard selectedSchedule != nil else{return}
            let destination = segue.destination as! IdealDetailViewController
            destination.idealSchedule = self.selectedSchedule
        }
    }
    
}
