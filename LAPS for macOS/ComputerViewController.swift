//
//  ComputerViewController.swift
//  LAPS for macOS
//
//  Created by Joshua D. Miller on 7/18/18.
//  The Pennsylvania State University
//  Icons made by Freepik http://www.freepik.com from Flaticon https://www.flaticon.com/ is licensed by Creative Commons BY 3.0 - http://creativecommons.org/licenses/by/3.0/"

import Cocoa
import OpenDirectory

var username: String = ""
var password: String = ""

class ComputerViewController: NSViewController {
    
    @IBOutlet var Computer_Name_field: NSTextField!
    @IBOutlet var LAPS_Password_field: NSTextField!
    @IBOutlet var Expiration_Date_field: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
// =====================================
// Get the LAPS Computer Password Button
// =====================================
   @IBAction func Get_Password(_ sender: Any) {
    
        // Date Formatting for application
        let dateFormatter = date_formatter()
        
        // Get Username, Password and Computer Name from input
        let Computer_Name: String = Computer_Name_field.stringValue
        LAPS_Password_field.stringValue = ""
        Expiration_Date_field.stringValue = ""
        // Retreieve the computer record for said computer
        guard let computer_record = try? connect_to_ad(username: username, password: password, computer_name: Computer_Name), computer_record != nil else {
            let laps_alert = NSAlert()
            laps_alert.messageText = "Unable to retrieve Computer Record"
            laps_alert.informativeText = """
            Please check the following and try again:
            \u{2022}  The domain controller is reachable
            \u{2022}  The specified credentials are correct
            \u{2022}  The computer name is spelled correctly
            """
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            return
        }
        
        // Get the LAPS Password
        guard let LAPS_Password = try? retrieve_laps_password(computer_record: computer_record!), LAPS_Password != nil else {
            let laps_alert = NSAlert()
            laps_alert.messageText = "Unable to retrieve LAPS Password"
            laps_alert.informativeText = "Please verify that the credentials supplied can read the LAPS password and the computer has had a LAPS password submitted to Active Directory and try the request again."
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            return
        }
        LAPS_Password_field.stringValue = LAPS_Password!
        
        // Get Expiration Time
        let exp_time = try? retrieve_laps_pw_exp_time(computer_record: computer_record!)
        
        // Convert it to Date and add it to the field
        let exp_date = time_conversion(time_type: TimeCon.epoch, exp_time: exp_time!, exp_days: nil) as! Date
        Expiration_Date_field.stringValue = dateFormatter.string(from: exp_date)

    }
    
// =======================================
// Expire the current LAPS Password Button
// =======================================
    @IBAction func Expire_Password(_ sender: Any) {
        // Get Username, Password and Computer Name from input
        let Computer_Name: String = Computer_Name_field.stringValue
        // Retreieve the computer record for said computer
        
        guard let computer_record = try? connect_to_ad(username: username, password: password, computer_name: Computer_Name), computer_record != nil else {
            let laps_alert = NSAlert()
            laps_alert.messageText = "Unable to retrieve Computer Record"
            laps_alert.informativeText = """
            Please check the following and try again:
            \u{2022}  The domain controller is reachable
            \u{2022}  The specified credentials are correct
            \u{2022}  The computer name is spelled correctly
            """
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            return
        }
        do {
            try reset_expiration_date(computer_record: computer_record!)
            let laps_alert = NSAlert()
            laps_alert.messageText = "Expiration Date Changed"
            laps_alert.informativeText = "The Expiration date of this computer has been set to January 1st, 2001 which upon next checkin will set a new LAPS Password"
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            Expiration_Date_field.stringValue = "Mon Jan 01, 2001 12:00:00 AM"
            return
        } catch {
            let laps_alert = NSAlert()
            laps_alert.messageText = "Unable to Reset Expiration Date"
            laps_alert.informativeText = """
            Please check the following and try again:
            \u{2022}  The domain controller is reachable
            \u{2022}  The specified credentials are correct
            \u{2022}  The computer name is spelled correctly
            """
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            return
        }
    }

}

