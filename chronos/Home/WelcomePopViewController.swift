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
    let propertyListDecoder = PropertyListDecoder()
    var idealSchedules : Array<IdealSchedule> = []
    var selectedSchedule : GeneratedSchedule!
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
        scheduleCollectionView.delegate = self
        scheduleCollectionView.dataSource = self
        
    }
    
//MARK: COLLECTIONVIEW SETUP
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idealSchedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //for cell sizing
        let cellWidth = 5*(scheduleCollectionView.bounds.size.width/8)
        let cellHeight = scheduleCollectionView.bounds.size.height - 40
        let insetX = (scheduleCollectionView.bounds.size.width-cellWidth)/2
        let insetY = 20
        scheduleCollectionView.contentInset = UIEdgeInsets(top: CGFloat(insetY), left: insetX, bottom: CGFloat(insetY), right: insetX)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCollectionViewCell
        let schedule = idealSchedules[indexPath.item]
        cell.scheduleTitle.text = schedule.name
        var dayString = "For days:"
        for day in schedule.days{
            dayString += " \(day)"
            if day != schedule.days[idealSchedules.count-1]{
                dayString += ","
            }
        }
        cell.scheduleDays.text = dayString
        cell.startLabel.text = "Start time: \(schedule.blocks[0].time/60):\(schedule.blocks[0].time%60)"
        cell.endLabel.text = "End time: \(schedule.blocks[schedule.blocks.count-1].time/60):\(schedule.blocks[schedule.blocks.count-1].time%60)"
        cell.layer.backgroundColor = UIColor.green.cgColor
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.scheduleCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
        let roundedIndex = round(index)
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
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
