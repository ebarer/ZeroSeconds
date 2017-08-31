//
//  ModelController.swift
//  ZeroSeconds
//
//  Created by Elliot Barer on 2017-08-24.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit
import UserNotifications

class ModelController: NSObject, UIPageViewControllerDataSource {

    var events: [Event] = []

    override init() {
        super.init()
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor(white: 0.9, alpha: 1.0)
        appearance.currentPageIndicatorTintColor = UIColor(red: 255/255.0, green: 149/255.0, blue: 0, alpha: 1.0)
    }

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.events.count == 0) || (index >= self.events.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.event = self.events[index < 0 ? 0 : index]
        return dataViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return events.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let vc = pageViewController.viewControllers?.first as? DataViewController {
            return indexOfViewController(vc)
        }

        return 0
    }

    func indexOfViewController(_ viewController: DataViewController) -> Int {
        guard let event = viewController.event else {
            return NSNotFound
        }
        
        return events.index(of: event) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? DataViewController else {
            return nil
        }

        var index = self.indexOfViewController(vc)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? DataViewController else {
            return nil
        }
        
        var index = self.indexOfViewController(vc)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.events.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    // MARL: - Persistence
    private var fileName = "Events.plist"
    
    func load() {
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }
        
        let path = dir.appendingPathComponent(fileName).path
        let loadedEvents = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Event]
        self.events = loadedEvents?.sorted(by: Event.sort) ?? [Event]()

        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule notifications for each event
        for event in events {
            event.scheduleNotification()
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("Notifications:")
            for (index, request) in requests.enumerated() {
                guard request.trigger is UNCalendarNotificationTrigger else {
                    continue
                }
                guard let date = Calendar.current.date(from: (request.trigger as! UNCalendarNotificationTrigger).dateComponents) else {
                    continue
                }
                
                print("\t\(index + 1): \(request.identifier) - \(Event.formatter.string(from: date))")
            }
        }
    }
    
    func save() -> Bool {
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return false
        }
        
        let path = dir.appendingPathComponent(fileName).path
        let saved = NSKeyedArchiver.archiveRootObject(events, toFile: path)
        return saved
    }
    
}

