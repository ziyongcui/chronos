//
//  IdealScheduleViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class IdealScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var idealBlocks : Array<Block> = []
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load blocks from (sample) save
        if let retrievedBlocks = try?Data(contentsOf: URLs.sampleBlocks){
            idealBlocks = try!propertyListDecoder.decode(Array<Block>.self, from: retrievedBlocks)
        }
        //tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let retrievedBlocks = try?Data(contentsOf: URLs.sampleBlocks){
            idealBlocks = try!propertyListDecoder.decode(Array<Block>.self, from: retrievedBlocks)
        }
        tableView.reloadData()
        print("viewWillAppear")
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
    
    func reload(){
        if let retrievedBlocks = try?Data(contentsOf: URLs.sampleBlocks){
            idealBlocks = try!propertyListDecoder.decode(Array<Block>.self, from: retrievedBlocks)
        }
        tableView.reloadData()
        self.presentedViewController?.dismiss(animated: true, completion: nil)
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
