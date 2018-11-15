//
//  CredentialsViewController.swift
//  LAPS for macOS
//
//  Created by Joshua D. Miller on 7/23/18.
//  The Pennsylvania State University
//

import Cocoa

class CredentialsViewController: NSViewController {
    
    @IBOutlet var Username_field: NSTextField!
    @IBOutlet var Password_field: NSSecureTextField!
    
    override func viewDidLoad() {
        
        let (keychain_username, keychain_password) = KeychainService.loadPassword(service: "edu.psu.LAPS-for-macOS")
        if keychain_username != nil {
            Username_field.stringValue = keychain_username!
            username = Username_field.stringValue
            Password_field.stringValue = keychain_password!
            password = Password_field.stringValue
            
        } else {
            return
        }
        super.viewDidLoad()
        // Do view setup here.
    }
    override func viewWillDisappear() {
        if Username_field.stringValue != "" && Password_field.stringValue != "" {
            username = Username_field.stringValue
            password = Password_field.stringValue
        }
    }

// ============================================
// Saving and updating Keychain
// ============================================

    @IBAction func Save_Credentials(_ sender: Any) {
        KeychainService.savePassword(service: "edu.psu.LAPS-for-macOS", account: Username_field.stringValue, data: Password_field.stringValue)
    }
    @IBAction func Update_Credentials(_ sender: Any) {
        KeychainService.updatePassword(service: "edu.psu.LAPS-for-macOS", account: Username_field.stringValue, data: Password_field.stringValue)
    }
    @IBAction func Remove_Credentials(_ sender: Any) {
        KeychainService.removePassword(service: "edu.psu.LAPS-for-macOS", account: Username_field.stringValue)
    }
}
