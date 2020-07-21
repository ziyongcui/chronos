//
//  WelcomePopViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 7/19/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class WelcomePopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    @IBOutlet weak var popupContainer: UIView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var beginDayButton: UIButton!
    let propertyListDecoder = PropertyListDecoder()
    var idealSchedules : Array<IdealSchedule> = []
    var selectedIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Light UI Setup
        popupContainer.layer.cornerRadius = 15.0
        //MAYBE SET ADJUSTFONTSIZETOFITWIDTH TO TRUE (low prio)
        
        //load in schedules-data to be displayed by collectionview
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            idealSchedules = try!propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules)
        }
        //ViewDidLoad CollectionView Setup
        
        //for cell sizing
        let cellWidth = 5*(scheduleCollectionView.bounds.size.width/8)
        let cellHeight = scheduleCollectionView.bounds.size.height - 40
        let insetX = (scheduleCollectionView.bounds.size.width-cellWidth)/2
        let insetY = CGFloat(20)
        let layout = scheduleCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        scheduleCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.reloadData()
        scheduleCollectionView.allowsMultipleSelection = false
        scheduleCollectionView.allowsSelection = true
    }
    
//MARK: COLLECTIONVIEW SETUP
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idealSchedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCollectionViewCell
        let schedule = idealSchedules[indexPath.item]
        cell.scheduleTitle.text = schedule.name
        var dayString = "For days:"
        for day in schedule.days{
            dayString += " \(day)"
            if day != schedule.days[schedule.days.count-1]{
                dayString += ","
            }
        }
        cell.scheduleDays.text = dayString
        cell.startLabel.text = "Start time: \(generateTimeString(time: schedule.blocks[0].time))"
        let endTime = schedule.blocks[schedule.blocks.count-1].time+schedule.blocks[schedule.blocks.count-1].duration
        cell.endLabel.text = "End time: \(generateTimeString(time: endTime))"
        cell.layer.backgroundColor = UIColor.green.cgColor
        cell.layer.cornerRadius = 15.0
        if selectedIndex==indexPath.item{
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.yellow.cgColor
        }
        return cell
    }
    
    func generateTimeString(time: Int) -> String{
        let minutes = time%60
        if minutes<10{
            return "\(time/60):0\(time%60)"
        }
        return "\(time/60):\(time%60)"
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let cell = scheduleCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0))
        cell!.layer.borderColor = UIColor.clear.cgColor
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.scheduleCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
        let roundedIndex = round(index)
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        selectedIndex = Int(roundedIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(selectedIndex)
        let cell = scheduleCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0))
        cell?.layer.borderColor = UIColor.yellow.cgColor
        cell?.layer.borderWidth = 3.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cell = scheduleCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0))
        cell?.layer.borderColor = UIColor.yellow.cgColor
        cell?.layer.borderWidth = 3.0
    }


    
//MARK: BUTTON FUNCTIONS
    @IBAction func makeAdjustments(_ sender: Any) {
//        call some segue to another view controller
    }
    
    @IBAction func beginDay(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
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
