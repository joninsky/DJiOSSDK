//
//  Extensions.swift
//  DJiOSSDK
//
//  Created by Jon Vogel on 12/28/16.
//  Copyright © 2016 Jon Vogel. All rights reserved.
//

import Foundation
import SystemConfiguration

public extension Configuration {
    
    static public var internetStatus: InternetStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    public func isDevelopmentEnvironment() -> Bool {
        guard let filePath = Bundle.main.path(forResource: "embedded", ofType:"mobileprovision") else {
            return false
        }
        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .ascii) else {
                return false
            }
            if string.contains("<key>aps-environment</key>\n\t\t<string>development</string>") {
                return true
            }
        } catch {}
        return false
    }
}

public extension Date {
    
    /// Gets you the 'Time ago' from now in human readable format. Very useful for 'Last Seen' text in a UI.
    public func timeAgoSinceNow() -> String {
        
        guard let yearDiff = self.dateComponents().year, let monthDiff = self.dateComponents().month, var weekDiff = self.dateComponents().day, let dayDiff = self.dateComponents().day, let hourDiff = self.dateComponents().hour, let minuteDiff = self.dateComponents().minute, let secondDiff = self.dateComponents().second else {
            return ""
        }
        weekDiff = weekDiff / 7
        
        var s = ""
        
        if yearDiff > 0 {
            s += "Over a year ago"
            return s
        }else if monthDiff > 0 {
            s += "\(monthDiff) "
            if monthDiff == 1 {
                s += "month ago"
            }else{
                s += "months ago"
            }
            return s
        }else if weekDiff > 0 {
            s += "\(weekDiff) "
            if weekDiff == 1 {
                s += "week ago"
            }else{
                s += "weeks ago"
            }
            return s
        }else if dayDiff > 0{
            s += "\(dayDiff) "
            if dayDiff == 1 {
                s += "day ago"
            }else{
                s += "days ago"
            }
            return s
        }else if hourDiff > 0{
            s += "\(hourDiff) "
            if hourDiff == 1 {
                s += "hour ago"
            }else{
                s += "hours ago"
            }
            return s
        }else if minuteDiff > 0{
            s += "\(minuteDiff) "
            if minuteDiff == 1 {
                s += "minute ago"
            }else{
                s += "minutes ago"
            }
            return s
        }else if secondDiff > 0 {
            if secondDiff < 5 {
                s += "Just now"
            }else{
                s += "\(secondDiff) seconds ago"
            }
            return s
        }else{
            s += "Just now"
            return s
        }
    }
    
    private func dateComponents() -> DateComponents {
        let calander = NSCalendar.current
        let set: Set<Calendar.Component> = [.second, .minute, .hour, .day, .month, .year]
        return calander.dateComponents(set, from: self, to: Date())
    }

}

