//
//  AddScheduleViewController.swift
//  chronos
//
//  Created by Paul Muser on 6/15/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit
class AddScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var days: UITextField!
    @IBOutlet var days1: UIPickerView?
    @IBOutlet weak var ADD: UIBarButtonItem!
    @IBOutlet weak var CANCEL: UIBarButtonItem!
    
    var selectedDays: Int?
    var daysList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerViewDays()
        dismissPickerViewDays()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func Add(_ sender: UIBarButtonItem) {

        guard name.text != nil && selectedDays != nil else{return}
        
        //saving schedule
        let createdSchedule = IdealSchedule(name: name.text!, blocks: [], days: ["Monday"], targetDate: "January 7, 2020", daysUntilDeadline: selectedDays!)
        createdSchedule.save()
        
        dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
        }
    }
    
    func createPickerViewDays() {
        
           days1 = UIPickerView()
        days1?.delegate = self
           days.inputView = days1
    }
    func dismissPickerViewDays() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       days.inputAccessoryView = toolBar
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return daysList.count
     // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(daysList[row])
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == days1{
            selectedDays = daysList[row] // selected item
            days.text = String(daysList[row])
        }
    }

    
    @objc func action() {
          view.endEditing(true)
    }

    
    
}
