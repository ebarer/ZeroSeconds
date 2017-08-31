//
//  RootViewController.swift
//  ZeroSeconds
//
//  Created by Elliot Barer on 2017-08-24.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    // MARK: - Outlets
    @IBOutlet var addButton: UIButton!
    @IBOutlet var emptyView: UIView!
    
    var pageViewController: UIPageViewController?
    let modelController = (UIApplication.shared.delegate as! AppDelegate).modelController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.pageViewController!.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController!.view)

        // Configure add button and bring to front of stack
        addButton.layer.cornerRadius = 15.0
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
        view.bringSubview(toFront: addButton)
        
        updatePageController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updatePageController(event: Event? = nil) {
        modelController.events = modelController.events.sorted(by: Event.sort)

        var index: Int = 0
        if let event = event {
            index = modelController.events.index(of: event) ?? 0
        }
        
        if noContent() == false {
            if let vc: DataViewController = self.modelController.viewControllerAtIndex(index, storyboard: self.storyboard!) {
                self.pageViewController!.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            }
        }
    }
    
    func noContent() -> Bool {
        if modelController.events.count == 0 {
            pageViewController?.view.isHidden = true
            emptyView.isHidden = false
            return true
        } else {
            pageViewController?.view.isHidden = false
            emptyView.isHidden = true
            return false
        }
    }
    
    @IBAction func closeSettings(segue: UIStoryboardSegue) {
        if let source = segue.source as? SettingsTableViewController {
            source.eventLabel.resignFirstResponder()
            
            // Save new event
            if source.event == nil {
                guard let name = source.eventLabel.text else {
                    return
                }

                let event = Event(name: name, date: source.timePicker.date)
                self.modelController.events.append(event)

                event.scheduleNotification()
                
                updatePageController(event: event)
            } else {
                updatePageController(event: source.event)
            }
            
            let saved = self.modelController.save()
            NSLog("Events saved ? %@", saved ? "true" : "false")
        }
    }
    
    @IBAction func deleteEvent(segue: UIStoryboardSegue) {
        if let source = segue.source as? DataViewController {
            deleteEventHelper(event: source.event, animated: true)
        }
        
        if let source = segue.source as? SettingsTableViewController {
            deleteEventHelper(event: source.event)
        }
    }
    
    func deleteEventHelper(event: Event?, animated: Bool = false) {
        guard let event = event, let index = self.modelController.events.index(of: event) else {
            return
        }

        self.modelController.events.remove(at: index)
        
        if noContent() == false {
            if let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(index - 1, storyboard: self.storyboard!) {
                self.pageViewController!.setViewControllers([startingViewController], direction: .reverse, animated: false, completion: nil)
            }
        }
        
        let saved = self.modelController.save()
        NSLog("Events saved ? %@", saved ? "true" : "false")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue")
    }
    
}

// MARK: - Global selection color

extension UIColor {
    
    class var selection: UIColor {
        return UIColor(red: 1, green: 150/255.0, blue: 0, alpha: 1)
    }
    
}
