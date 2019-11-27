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
    case customtime
}

// Windows to Epoch time converter and vice versa
func time_conversion(time_type: TimeCon, exp_time: String?, exp_days: Int?) -> Any? {
    switch time_type {
    case .epoch:
        let converted_time = Double((Int(exp_time!)! / 10000000 - 11644473600))
        let pw_expires_date = Date(timeIntervalSince1970: converted_time)
        return(pw_expires_date)
    case .customtime:
        let new_conv_time = String((Int(exp_time!)! + 11644473600) * 10000000)
        return(new_conv_time)
    }
}
