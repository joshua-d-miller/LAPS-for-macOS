//
//  Keychain.swift
//  LAPS for macOS
//
//  Created by Joshua D. Miller on 7/21/18.
//  The Pennsylvania State University
//  Sources: https://stackoverflow.com/a/37539998/1694526
//  https://developer.apple.com/documentation/security/keychain_services/keychain_items/searching_for_keychain_items

import Cocoa
import Security


// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {
    
    class func updatePassword(service: String, account:String, data: String) {
        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(
                objects: [kSecClassGenericPasswordValue, service, account, kCFBooleanTrue, kSecMatchLimitOneValue],
                forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
            
            let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue:dataFromString] as CFDictionary)
            
            if (status != errSecSuccess) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Read failed: \(err)")
                }
            }
        }
    }
    
    
    class func removePassword(service: String, account:String) {
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPasswordValue, service, account, kCFBooleanTrue, kSecMatchLimitOneValue],
            forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Remove failed: \(err)")
            }
        }
        
    }
    
    
    class func savePassword(service: String, account:String, data: String) {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(
                objects: [kSecClassGenericPasswordValue, service, account, dataFromString],
                forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
            
            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if (status != errSecSuccess) {    // Always check the status
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Write failed: \(err)")
                }
            }
        }
    }
    
    class func loadPassword(service: String) -> (String?, String?) {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(
            objects: [kSecClassGenericPassword, service, kCFBooleanTrue, kCFBooleanTrue, kSecMatchLimitOne],
            forKeys: [kSecClass, kSecAttrServiceValue, kSecReturnData, kSecReturnAttributes, kSecMatchLimit])
        
        var item: CFTypeRef?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &item)
        var account: String? = nil
        var password: String? = nil
        
        if status == errSecSuccess {
            if let existingItem = item as? [String:Any] {
                // Get Password Data
                let passwordData = existingItem[kSecValueData as String] as? Data
                password = String(data: passwordData!, encoding: String.Encoding.utf8)
                // Get account name
                account = existingItem[kSecAttrAccount as String] as? String
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
            return(nil, nil)
        }

        return(account,password)
    }
}
