//
//  GeneratedScheduleViewController.swift
//  chronos
//
//  Created by Paul Development on 12/29/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//
import UIKit

class GeneratedScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var selectedSchedule : GeneratedSchedule? = nil
    var generatedSchedules : Array<GeneratedSchedule> = []
    let propertyListDecoder = PropertyListDecoder()
    
    
    //MARK: -HANDLING VIEW LOADS AND RE-ENTRY
    @objc func loadList(notification: NSNotification){
        //load data here
        reload()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        //load blocks from (sample) save
        if let retrievedSchedules = try?Data(contentsOf: URLs.finishedSchedules){
            generatedSchedules = try!propertyListDecoder.decode(Array<GeneratedSchedule>.self, from: retrievedSchedules)
        }
        else{
            //handle no schedules scenario
        }
        
       
        
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func reload(){
        if let retrievedSchedules = try?Data(contentsOf: URLs.finishedSchedules){
            generatedSchedules = try!propertyListDecoder.decode(Array<GeneratedSchedule>.self, from: retrievedSchedules)
        }
        tableView.reloadData()
    }
    
    //MARK: - TABLE VIEW CONFIGURATION
    
    //makes each item an individual section to utilize header spacing
    func numberOfSections(in tableView: UITableView) -> Int {
        return generatedSchedules.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneratedScheduleCell", for: indexPath) as! GeneratedScheduleTableViewCell
        cell.titleLabel.text = generatedSchedules[indexPath.section].name
        
        //some small UI enhancing
    
        cell.layer.cornerRadius = 0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1
        cell.selectionStyle = .none
        return cell
    }
    
    //code to run when cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSchedule = generatedSchedules[indexPath.section]
        self.performSegue(withIdentifier: "GeneratedScheduleToDetail", sender: nil)
    }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            generatedSchedules[indexPath.section].delete(indexPath: indexPath)

            
                        // delete the table view row
            print(generatedSchedules)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            generatedSchedules.remove(at: indexPath.section)
            print(generatedSchedules)
            tableView.reloadData()
            //tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the selected schedule to the IdealDetailViewController
        if segue.identifier == "GeneratedScheduleToDetail"{
            guard selectedSchedule != nil else{return}
            let destination = segue.destination as! GeneratedDetailViewController
            destination.generatedSchedule = self.selectedSchedule
        }
    }
    
}

