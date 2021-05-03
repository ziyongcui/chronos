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
    @IBOutlet weak var desc: UITextField!
    //@IBOutlet weak var days: UITextField!
    //var daysSelected : Int?
    @IBOutlet weak var ADD: UIBarButtonItem!
    @IBOutlet weak var CANCEL: UIBarButtonItem!
    //@IBOutlet weak var day: UITextField!
    //var preSelectedValues : [String] = []
    //var daySelected : [String] = []
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    let propertyListEncoder = PropertyListEncoder()
    let propertyListDecoder = PropertyListDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //Looks for single or multiple taps.
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))

        view.addGestureRecognizer(tap)
        
            
        
        //if isEditing == true {}
        
       //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
       //tap.cancelsTouchesInView = false

       //view.addGestureRecognizer(tap)
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func Add(_ sender: UIBarButtonItem) {

        guard name.text != nil && desc.text != nil else{return}
        
        //saving schedule
        let createdSchedule = IdealSchedule(name: name.text!, desc: desc.text!)
        idealSchedules.append(createdSchedule)
        IdealSchedule.save()
        
        dismiss(animated: true){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissedForm"), object: nil)
        }
    }
    
    
    
    @objc func action() {
          view.endEditing(true)
    }

    
    
}
