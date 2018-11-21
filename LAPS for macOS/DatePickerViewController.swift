//
//  DatePickerViewController.swift
//  LAPS for macOS
//
//  Created by Joshua D. Miller on 11/20/18.
//  The Pennsylvania State University
//

import Cocoa
import Foundation

class DatePickerViewController: NSViewController {
    
    @IBOutlet var Date_Picker_Field: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Date_Picker_Field.dateValue = Date()
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    

    @IBAction func SetDate(_ sender: Any) {
    custom_date = Date_Picker_Field.dateValue
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadView"), object: nil)
        self.dismiss(self)
    }
}
