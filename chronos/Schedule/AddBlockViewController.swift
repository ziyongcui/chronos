//
//  AddBlockViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class AddBlockViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //UI elements

    @IBOutlet weak var rigid: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var priority: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet var rigid1: UIPickerView?
    @IBOutlet var duration1: UIPickerView?
    @IBOutlet var priority1: UIPickerView?
    @IBOutlet weak var ADD: UIBarButtonItem!
    @IBOutlet weak var CANCEL: UIBarButtonItem!
    @IBOutlet weak var time: UITextField!
    @IBOutlet var time1: UIPickerView?

    var hourList = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var hourListDuration = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var minuteList = ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    var TODList = [" AM", " PM"]
    let numberOfComponents = 4
    //private var
    var selectedTime: String?
    var selectedRigidity: Bool?
    var rigidList = [true, false]
    var selectedPriority: Int?
    var priorityList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var selectedDuration: String?
    var durationList = ["00:00", "00:30", "01:00", "01:30", "02:00"]
    
    //decoders and passed information
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()
    var idealSchedule : IdealSchedule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerViewRigid()
        dismissPickerViewRigid()
        createPickerViewTime()
        dismissPickerViewTime()
        createPickerViewDuration()
        dismissPickerViewDuration()
        createPickerViewPriority()
        dismissPickerViewPriority()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func Add(_ sender: UIBarButtonItem) {
        guard name.text != nil && selectedRigidity != nil && selectedPriority != nil else{return} //add more conditions
        let durationMin = duration.text
        let timeMin = time.text
        let dateFormatterTime = DateFormatter()//calculate minutes of event
        dateFormatterTime.dateFormat = "hh:mm a" //Your date format
        dateFormatterTime.timeZone = TimeZone.current //Current time zone
        let dateFormatterDuration = DateFormatter()//calculate minutes of event
        dateFormatterDuration.dateFormat = "hh:mm" //Your date format
        dateFormatterDuration.timeZone = TimeZone.current //Current time zone
        let dateDuration = dateFormatterDuration.date(from: durationMin!) //according to date format your date string
        let dateTime = dateFormatterTime.date(from: timeMin!)
        print(dateDuration ?? "") //Convert String to Date
        print(dateTime ?? "")
        let calendar = Calendar.current
        let compDuration = calendar.dateComponents([.hour, .minute], from: dateDuration!)
        let compTime = calendar.dateComponents([.hour, .minute], from: dateTime!)
        let hourDuration = compDuration.hour ?? 0
        let minuteDuration = compDuration.minute ?? 0
        let hourTime = compTime.hour ?? 0
        let minuteTime = compTime.minute ?? 0
        //let finalMinutDuration:Int = (hourDuration * 60) + minuteDuration
        //let finalMinutTime:Int = (hourTime * 60) + minuteTime
        
        let durationTime = Time(minute: minuteDuration, hour: hourDuration)
        let startTime = Time(minute: minuteTime, hour: hourTime)
        //saving block
        let createdBlock = Block(time: startTime, duration: durationTime, completionDuration: Time.empty, name: name.text!, rigid: selectedRigidity!, priority: selectedPriority!, status: "not attempted")
        //Improve Insert func (check for time conflicts etc.)
        idealSchedule.blocks.append(createdBlock)
        idealSchedule.blocks = idealSchedule.blocks.sorted(by: {$0.time.toMinutes()<$1.time.toMinutes()})
        idealSchedule.save()
        
        dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
        }
    }
    
    func createPickerViewTime() {
        
           time1 = UIPickerView()
           time1?.delegate = self
           time.inputView = time1
    }
    func dismissPickerViewTime() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       time.inputAccessoryView = toolBar
    }
    func createPickerViewDuration() {
        
           duration1 = UIPickerView()
           duration1?.delegate = self
           duration.inputView = duration1
    }
    func dismissPickerViewDuration() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       duration.inputAccessoryView = toolBar
    }
    func createPickerViewRigid() {
        
           rigid1 = UIPickerView()
        rigid1?.delegate = self
           rigid.inputView = rigid1
    }
    func dismissPickerViewRigid() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       rigid.inputAccessoryView = toolBar
    }
    func createPickerViewPriority() {
        
           priority1 = UIPickerView()
        priority1?.delegate = self
           priority.inputView = priority1
    }
    func dismissPickerViewPriority() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       priority.inputAccessoryView = toolBar
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == time1{
            return numberOfComponents
        }
        else if pickerView == duration1{
            return 3
        }
        else{
            return 1 // number of session
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == time1{
            if component == 0 {
                return hourList.count
            }else if component == 2 {
                return minuteList.count
            }else if component == 3 {
                return TODList.count
            }else {
                return 1
            }
        }
        else if pickerView == rigid1{
            return rigidList.count
        }
        else if pickerView == duration1{
            if component == 0 {
                return hourListDuration.count
            }else if component == 2 {
                return minuteList.count
            }else {
                return 1
            }
        }
        return priorityList.count
     // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == time1{
            if component == 0 {
                return "\(hourList[row])"
            }else if component == 1 {
                return ":"
            }else if component == 2 {
                return "\(minuteList[row])"
            }else {
                return "\(TODList[row])"
            } // dropdown item
        }
        else if pickerView == rigid1{
            return String(rigidList[row])
        }
        else if pickerView == duration1{
            if component == 0 {
                return "\(hourListDuration[row])"
            }else if component == 1 {
                return ":"
            }else if component == 2 {
                return "\(minuteList[row])"
            }
        }
        return String(priorityList[row])
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == time1{
            let hourIndex = pickerView.selectedRow(inComponent: 0)
            let minuteIndex = pickerView.selectedRow(inComponent: 2)
            let TODIndex = pickerView.selectedRow(inComponent: 3)
            time.text = "\(hourList[hourIndex]):\(minuteList[minuteIndex])\(TODList[TODIndex])" // selected item
            
        }
        if pickerView == rigid1{
            selectedRigidity = rigidList[row] // selected item
            rigid.text = String(rigidList[row])
        }
        if pickerView == duration1{
            let hourIndex = pickerView.selectedRow(inComponent: 0)
            let minuteIndex = pickerView.selectedRow(inComponent: 2)
            duration.text = "\(hourListDuration[hourIndex]):\(minuteList[minuteIndex])" // selected item
        }
        if pickerView == priority1{
            selectedPriority = priorityList[row] // selected item
            priority.text = String(priorityList[row])
        }
    }

    
    @objc func action() {
          view.endEditing(true)
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
