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
var custom_date: Date?

class ComputerViewController: NSViewController {
    
    @IBOutlet var Computer_Name_field: NSTextField!
    @IBOutlet var LAPS_Password_field: NSTextField!
    @IBOutlet var Expiration_Date_field: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidAppear), name:NSNotification.Name(rawValue: "loadView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOFReceivedNotication), name:NSNotification.Name(rawValue: "DatePopup"), object: nil)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    override func viewDidAppear() {
        if custom_date != nil {
            Expiration_Date_field.stringValue = date_formatter().string(from: custom_date!)
        }
    }

    @objc func methodOFReceivedNotication(notification: NSNotification) {
        self.performSegue(withIdentifier: "DatePopup", sender: self)
    }
// =====================================
// Get the LAPS Computer Password Return
// =====================================

    @IBAction func Copy_Clipboard(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(LAPS_Password_field.stringValue, forType: NSPasteboard.PasteboardType.string)
    }
    
    
// =====================================
// Get the LAPS Computer Password Button
// =====================================
   @IBAction func Get_Password(_ sender: Any) {
        
        // Get Username, Password and Computer Name from input
        let Computer_Name: String = Computer_Name_field.stringValue
        LAPS_Password_field.stringValue = ""
        Expiration_Date_field.stringValue = ""
        // Retreieve the computer record for said computer
        guard let computer_record = ((try? connect_to_ad(username: username, password: password, computer_name: Computer_Name)) as ODRecord??), computer_record != nil else {
            let laps_alert = NSAlert()
            laps_alert.messageText = "Unable to retrieve Computer Record"
            laps_alert.informativeText = """
            Please check the following and try again:
            \u{2022}  The domain controller is reachable
            \u{2022}  The specified credentials are correct
            \u{2022}  The computer name is spelled correctly
            \u{2022}  The computer is bound to Active Directory
            """
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            return
        }
        
        // Get the LAPS Password
        guard let LAPS_Password = ((try? retrieve_laps_password(computer_record: computer_record!)) as String??), LAPS_Password != nil else {
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
        let exp_time = ((try? retrieve_laps_pw_exp_time(computer_record: computer_record!)) as String??)
        
        // Convert it to Date and add it to the field
        let exp_date = time_conversion(time_type: TimeCon.epoch, exp_time: exp_time!, exp_days: nil) as! Date
        Expiration_Date_field.stringValue = date_formatter().string(from: exp_date)

    }
// =======================================
// Copy Password to Clipboard Button
// =======================================
    
    
    
// =======================================
// Expire the current LAPS Password Button
// =======================================
    @IBAction func Expire_Password(_ sender: Any) {
        // Get Username, Password and Computer Name from input
        let Computer_Name: String = Computer_Name_field.stringValue
        // Retreieve the computer record for said computer
        
        guard let computer_record = ((try? connect_to_ad(username: username, password: password, computer_name: Computer_Name)) as ODRecord??), computer_record != nil else {
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
            if custom_date != nil {
                laps_alert.informativeText = "The Expiration date of this computer has been set to " + date_formatter().string(from: custom_date!) + " which upon next checkin will set a new LAPS Password"
            }
            else {
                laps_alert.informativeText = "The Expiration date of this computer has been set to Mon Jan 01, 2001 12:00:00 AM which upon next checkin will set a new LAPS Password"
                Expiration_Date_field.stringValue = "Mon Jan 01, 2001 12:00:00 AM"
            }
            laps_alert.addButton(withTitle: "OK")
            laps_alert.alertStyle = NSAlert.Style.warning
            laps_alert.runModal()
            custom_date = nil
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
// ********************************
// Custom Class for Expiration Date
// text field so we can trigger the
// segue when clicking into the
// text field. Source:
// https://stackoverflow.com/questions/27604192/ios-how-to-segue-programmatically-using-swift
// ********************************
class ExpDateField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DatePopup"), object: nil)
    }
}
