//
//  CounterDate.swift
//  Countdown
//
//  Created by Elliot Barer on 2017-08-16.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit
import UserNotifications

class Event: NSObject, NSCoding {
    
    var name: String
    var date: Date
    
    class var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        return formatter
    }
    
    init(name: String, date dateString: String) {
        self.name = name
        
        if let date = Event.formatter.date(from: dateString) {
            self.date = date
        } else {
            self.date = Date()
        }
    }
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {
            return nil
        }
        
        guard let date = aDecoder.decodeObject(forKey: "date") as? Date else {
            return nil
        }
        
        self.name = name
        self.date = date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(date, forKey: "date")
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name && lhs.date.compare(rhs.date) == .orderedSame
    }
    
    func scheduleNotification() {
        if self.date.compare(Date()) == .orderedDescending {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.body = "Finished counting down to \(self.name)!"
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(identifier: self.name, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let date = Calendar.current.date(from: components), error == nil {
                    print("Notification scheduled for \(Event.formatter.string(from: date)) for \"\(self.name)\".")
                } else {
                    print("Error scheduling notification for \(self.name).")
                }
            }
        }
    }
    
}

extension Event {
    var difference: [Calendar.Component : Int] {
        var components = DateComponents()
        var difference = [Calendar.Component : Int]()
        
        if Date().compare(self.date) == .orderedAscending {
            components = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: Date(), to: self.date)
            
            if components.day != nil && components.day! > 0 {
                difference[.day] = components.day!
            }
            
            if components.hour != nil && components.hour! > 0 {
                difference[.hour] = components.hour!
            }
            
            if components.minute != nil && components.minute! > 0 {
                difference[.minute] = components.minute!
            }
            
            difference[.second] = components.second ?? 0
        }
        
        return difference
    }
    
    class func sort(e1: Event, e2: Event) -> Bool {
        let today = Date()
        
        let compareResults = e1.date.compare(e2.date)
        switch compareResults {
        case .orderedSame:
            return e1.name.compare(e2.name) == .orderedAscending
        case .orderedAscending:
            return e1.date.compare(today) == .orderedDescending
        case .orderedDescending:
            return e2.date.compare(today) == .orderedAscending
        }

    }
}
