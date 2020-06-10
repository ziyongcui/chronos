//
//  AddBlockViewController.swift
//  chronos
//
//  Created by Ronnoc Gnad on 6/4/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

class AddBlockViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var selectedTime: String?
    var timeList = ["8:00", "9:00", "10:00", "11:00", "12:00"]
    var selectedRigidity: Bool?
    var rigidList = [true, false]
    var selectedPriority: Int?
    var priorityList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var selectedDuration: String?
    var durationList = ["0:00", "0:30", "1:00", "1:30", "2:00"]
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var rigid: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var priority: UITextField!
    @IBOutlet var time1: UIPickerView?
    @IBOutlet var rigid1: UIPickerView?
    @IBOutlet var duration1: UIPickerView?
    @IBOutlet var priority1: UIPickerView?
    @IBAction func Add(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
      }
    @IBOutlet weak var ADD: UIBarButtonItem!
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
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == time1{
            return timeList.count
        }
        else if pickerView == rigid1{
            return rigidList.count
        }
        else if pickerView == duration1{
            return durationList.count
        }
        return priorityList.count
     // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == time1{
            return timeList[row] // dropdown item
        }
        else if pickerView == rigid1{
            return String(rigidList[row])
        }
        else if pickerView == duration1{
            return durationList[row]
        }
        return String(priorityList[row])
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == time1{
            selectedTime = timeList[row] // selected item
            time.text = selectedTime
        }
        if pickerView == rigid1{
            selectedRigidity = rigidList[row] // selected item
            rigid.text = String(rigidList[row])
        }
        if pickerView == duration1{
            selectedDuration = durationList[row] // selected item
            duration.text = selectedDuration
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
