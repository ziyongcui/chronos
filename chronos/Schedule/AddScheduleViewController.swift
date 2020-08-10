//
//  AddScheduleViewController.swift
//  chronos
//
//  Created by Paul Muser on 6/15/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit
class AddScheduleViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var days: UITextField!
    var daysSelected : Int?
    @IBOutlet weak var ADD: UIBarButtonItem!
    @IBOutlet weak var CANCEL: UIBarButtonItem!
    @IBOutlet weak var day: UITextField!
    var preSelectedValues : [String] = []
    var daySelected : [String] = []
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func showOptionsActionDays(_ sender: Any) {
        let pickerData : [[String:String]] = [
            [
                "value": "1",
                "display": "1"
            ],
            [
                "value": "2",
                "display": "2"
            ],
            [
                "value": "3",
                "display": "3"
            ],
            [
                "value": "4",
                "display": "4"
            ],
            [
                "value": "5",
                "display": "5"
            ],
            [
                "value": "6",
                "display": "6"
            ],
            [
                "value": "7",
                "display": "7"
            ],
            [
                "value": "8",
                "display": "8"
            ],
            [
                "value": "9",
                "display": "9"
            ],
            [
                "value": "10",
                "display": "10"
            ]
            
        ]
        
        
        
        SinglePickerDialog().show(title: "Pick Days",doneButtonTitle:"Select", cancelButtonTitle:"Cancel" ,options: pickerData, selected:  preSelectedValues) {
            values -> Void in
            print("callBack \(values)")
            self.preSelectedValues = values.compactMap {return $0["value"]}
            
            let displayValues = values.compactMap {return $0["display"]}
            self.days.text = "\(displayValues.joined(separator: ", "))"
            self.daysSelected = Int(displayValues[0])
            
        }
    }
    @IBAction func showOptionsAction(_ sender: Any) {
        let pickerData : [[String:String]] = [
            [
                "value":"Monday",
                "display":"Monday"
            ],
            [
                "value": "Tuesday",
                "display":"Tuesday"
            ],
            [
                "value": "Wednesday",
                "display":"Wednesday"
            ],
            [
                "value":"Thursday",
                "display":"Thursday"
            ],
            [
                "value": "Friday",
                "display":"Friday"
            ],
            [
                "value": "Saturday",
                "display":"Saturday"
            ],
            [
                "value": "Sunday",
                "display":"Sunday"
            ]
            
        ]
        
        
        
        MultiPickerDialog().show(title: "Pick Day",doneButtonTitle:"Select", cancelButtonTitle:"Cancel" ,options: pickerData, selected:  preSelectedValues) {
            values -> Void in
            print("callBack \(values)")
            self.preSelectedValues = values.compactMap {return $0["value"]}
            
            let displayValues = values.compactMap {return $0["display"]}
            self.day.text = "\(displayValues.joined(separator: ", "))"
            self.daySelected = displayValues
            
        }
    }
    
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

       //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
       //tap.cancelsTouchesInView = false

       view.addGestureRecognizer(tap)
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func Add(_ sender: UIBarButtonItem) {

        guard name.text != nil && daysSelected != nil else{return}
        
        //saving schedule
        let createdSchedule = IdealSchedule(name: name.text!, blocks: [], days: daySelected, targetDate: Date(), daysUntilDeadline: daysSelected!)
        createdSchedule.save()
        
        dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
        }
    }
    
    
    
    @objc func action() {
          view.endEditing(true)
    }

    
    
}
