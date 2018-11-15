//
//  TimeConversion.swift
//  macOSLAPS
//
//  Created by Joshua D. Miller on 6/13/17.
//  The Pennsylvania State University
//
import Foundation

enum TimeCon {
    case epoch
    case windows
}

// Windows to Epoch time converter and vice versa
func time_conversion(time_type: TimeCon, exp_time: String?, exp_days: Int?) -> Any? {
    switch time_type {
    case .epoch:
        let converted_time = Double((Int(exp_time!)! / 10000000 - 11644473600))
        let pw_expires_date = Date(timeIntervalSince1970: converted_time)
        return(pw_expires_date)
    
    case .windows:
        let new_expiration_time = Calendar.current.date(byAdding: .day, value: exp_days!, to: Date())!
        let new_conv_time = Int(new_expiration_time.timeIntervalSince1970)
        let new_ad_expiration_time = String((new_conv_time + 11644473600) * 10000000)
        return(new_ad_expiration_time)
    }
}
