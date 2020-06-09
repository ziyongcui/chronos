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
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var rigid: UITextField!
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return timeList.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return timeList[row] // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedTime = timeList[row] // selected item
    time.text = selectedTime
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        dismissPickerView()
        // Do any additional setup after loading the view.
    }
    func createPickerView() {
           let pickerView = UIPickerView()
           pickerView.delegate = self
           time.inputView = pickerView
    }
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       time.inputAccessoryView = toolBar
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
