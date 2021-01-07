//
//  GeneratedScheduleViewController.swift
//  chronos
//
//  Created by Paul Development on 12/29/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//
import UIKit

class GeneratedScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet var minuteChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!

    var selectedSchedule : GeneratedSchedule? = nil
    var generatedSchedules : Array<GeneratedSchedule> = []
    let propertyListDecoder = PropertyListDecoder()
    
    
    //MARK: -HANDLING VIEW LOADS AND RE-ENTRY
    @objc func loadList(notification: NSNotification){
        //load data here
        reload()
    }
    override func viewDidAppear(_ animated: Bool) {
        let percentages = calcPercent()
        let completed = percentages.0
        let unfinished = percentages.1
        let completedInt = percentages.2
        let totalInt = percentages.3
        if completedInt >= totalInt && totalInt != 0 {
            pieChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemBlue),
                Slice(percent: 0.5, color: UIColor.systemBlue)
                
            ]
        }
        else if unfinished >= 1 && totalInt != 0 {
            pieChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemGray),
                Slice(percent: 0.5, color: UIColor.systemGray)
                
            ]
        }
        else if totalInt > 0 {
            pieChartView.slices = [
                Slice(percent: CGFloat(unfinished), color: UIColor.systemGray),
                Slice(percent: CGFloat(completed), color: UIColor.systemBlue)
                
            ]
        }
        else{
            pieChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemGray),
                Slice(percent: 0.5, color: UIColor.systemGray)
                
            ]
        }
        pieChartView.animateChart()
        tasksLabel.text = "\(completedInt)/\(totalInt) Tasks Finished!"
        let minutePercentages = calcPercentMinutes()
        let completedMinutes = minutePercentages.0
        let unfinishedMinutes = minutePercentages.1
        let completedMinutesInt = minutePercentages.2
        let totalMinutesInt = minutePercentages.3
        if completedMinutesInt >= totalMinutesInt && totalMinutesInt != 0 {
            minuteChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemBlue),
                Slice(percent: 0.5, color: UIColor.systemBlue)
                
            ]
        }
        else if unfinishedMinutes >= 1 && totalMinutesInt != 0 {
            minuteChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemGray),
                Slice(percent: 0.5, color: UIColor.systemGray)
                
            ]
        }
        else if totalMinutesInt > 0
        {
            minuteChartView.slices = [
                Slice(percent: CGFloat(unfinishedMinutes), color: UIColor.systemGray),
                Slice(percent: CGFloat(completedMinutes), color: UIColor.systemBlue)
                
            ]
        }
        else{
            minuteChartView.slices = [
                Slice(percent: 0.5, color: UIColor.systemGray),
                Slice(percent: 0.5, color: UIColor.systemGray)
                
            ]
        }
        
        minuteChartView.animateChart()
        minutesLabel.text = "\(completedMinutesInt)/\(totalMinutesInt) Desired Minutes Spent Working!"
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
    func calcPercent() -> (Double, Double, Int, Int){
        var completedTasks = 0
        var unfinishedTasks = 0
        var totalTasks = 0
        for generatedSchedule in generatedSchedules{
            for block in generatedSchedule.blocks{
                if block.status == "completed"
                {
                    completedTasks+=1
                }
                else{
                    unfinishedTasks+=1
                }
                totalTasks+=1
            }
        }
        print(Double(completedTasks)/Double(totalTasks))
        return (Double(completedTasks)/Double(totalTasks), Double(unfinishedTasks)/Double(totalTasks), completedTasks, totalTasks)
    }
    func calcPercentMinutes() -> (Double, Double, Int, Int){
        var completedMinutes = 0
        var unfinishedMinutes = 0
        var totalMinutes = 0
        for generatedSchedule in generatedSchedules{
            for block in generatedSchedule.blocks{
                if block.status == "completed"
                {
                    completedMinutes+=block.completionDuration.toMinutes()
                }
                totalMinutes+=block.duration.toMinutes()
            }
        }
        unfinishedMinutes = totalMinutes - completedMinutes
        if unfinishedMinutes<0 {
            unfinishedMinutes=0
        }
        return (Double(completedMinutes)/Double(totalMinutes), Double(unfinishedMinutes)/Double(totalMinutes), completedMinutes, totalMinutes)
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

