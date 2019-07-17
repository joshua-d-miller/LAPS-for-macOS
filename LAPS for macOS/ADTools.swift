//  ============================================
//  ADTools.swift
//  LAPS for macOS - Similar to the macOSLAPS
//  script but a bit "refined"
//  ============================================
//  Created by Joshua D. Miller on 6/13/17.
//  The Pennsylvania State University
//  Last Update on July 17, 2019
//  ============================================

import Cocoa
import Foundation
import OpenDirectory
import SystemConfiguration

// ========================================================
// Connect to Active Directory with Specified Computer Name
// ========================================================
func connect_to_ad(username: String, password: String, computer_name: String) throws -> ODRecord? {

    // Create Net Config
    let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil)
    // Get Active Directory Info
    let ad_info = [ SCDynamicStoreCopyValue(net_config, "com.apple.opendirectoryd.ActiveDirectory" as CFString)]
    // Convert ad_info variable to dictionary as it seems there is support for multiple directories
    let adDict = ad_info[0] as? NSDictionary ?? nil
    // Make sure we are bound to Active Directory
    if adDict == nil {
        return(nil)
    }
    // Use Open Directory to Connect to Active Directory
    let session = ODSession.default()
    // Create the Active Directory Path in case Search Paths are disabled
    let ad_path = "\(adDict?["NodeName"] as! String)/\(adDict?["DomainNameDns"] as! String)"
    // Format Computer Name
    let ad_computer_name = computer_name + "$"
    // Connect to node
    let node = try ODNode.init(session: session, name: ad_path)
    // Add our credentials to the node
    try node.setCredentialsWithRecordType(nil, recordName: username, password: password)
    // Open a query
    let query = try ODQuery.init(node: node, forRecordTypes: kODRecordTypeComputers, attribute: kODAttributeTypeRecordName, matchType: UInt32(kODMatchEqualTo), queryValues: ad_computer_name, returnAttributes: kODAttributeTypeNativeOnly, maximumResults: 0)
    // Save the results
    let result = try query.resultsAllowingPartial(false)
    // Save the computer's record
    if let record = result.first as? ODRecord {
        return(record)
    }
    return(nil)
}

// ================================================================
// Active Directory Tools for reading attributes of computer record
// ================================================================
// Get the LAPS Password
func retrieve_laps_password(computer_record: ODRecord) throws -> String? {
    // Retreive the password from the Directory Service after we connected with privileged credential
    let laps_password: String
    
    do {
        laps_password = (try computer_record.values(forAttribute: "dsAttrTypeNative:ms-Mcs-AdmPwd").first as? String)!
    } catch {
        throw error
    }
    
    return(laps_password)
}

// Get the LAPS Password Expiration time
func retrieve_laps_pw_exp_time(computer_record: ODRecord) throws -> String? {
    // Retreive the LAPS password Expiration Time from Active Directory for the computer
    guard let expirationtime = try computer_record.values(forAttribute: "dsAttrTypeNative:ms-Mcs-AdmPwdExpirationTime").first as? String else {
        return(nil)
    }
    return(expirationtime)
}

// =================================================================
// Start a LAPS Password Reset
// =================================================================
func reset_expiration_date(computer_record: ODRecord) throws {
    // Set the expiration date on the computer as 01/01/2001 which will allow
    // the computer to change its LAPS password upon next check-in
    let default_expiration_time = "126227988000000000"
    if custom_date != nil {
        let custom_converted_time = String(Int((custom_date?.timeIntervalSince1970)!))
        let custom_expiration_time = time_conversion(time_type: TimeCon.customtime, exp_time: custom_converted_time, exp_days: nil)
        try computer_record.setValue(custom_expiration_time, forAttribute: "dsAttrTypeNative:ms-Mcs-AdmPwdExpirationTime")
    }
    else {
        try computer_record.setValue(default_expiration_time, forAttribute: "dsAttrTypeNative:ms-Mcs-AdmPwdExpirationTime")
    }
}
