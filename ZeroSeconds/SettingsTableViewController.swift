//
//  SettingsTableViewController.swift
//  Countdown
//
//  Created by Elliot Barer on 2017-07-31.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: - Constants
    let PICKER_HEIGHT_HIDDEN: CGFloat = 0.0
    let PICKER_HEIGHT_VISIBLE: CGFloat = 200.0
    
    // MARK: - Properties
    var event: Event?
    let formatter = DateFormatter()
    var editingDate = true
    var editingTime = false
    
    // MARK: - Outlets
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var eventLabel: UITextField!
    @IBOutlet var dateDetailLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timeDetailLabel: UILabel!
    @IBOutlet var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get event name
        //let placeholder = NSAttributedString(string: "Name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkGray])
        //eventLabel.attributedPlaceholder = placeholder
        
        if event == nil {
            self.title = "New Counter"
            doneButton.isEnabled = false
        } else {
            self.title = "Details"
            eventLabel.text = event?.name
            doneButton.isEnabled = true
            self.navigationItem.leftBarButtonItem = nil
        }
        
        // Setup date picker
        if let date = event?.date {
            datePicker.date = date
        } else {
            datePicker.date = Date()
        }
        
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: Calendar.Component.weekOfYear, value: 999, to: Date())
        //datePicker.setValue(UIColor.white, forKey: "textColor")
        formatter.dateFormat = "MMM d, yyyy"
        dateDetailLabel.text = formatter.string(from: datePicker.date)
        dateDetailLabel.textColor = UIColor.selection
        
        // Setup time picker
        if let date = event?.date {
            timePicker.date = date
        } else {
            if let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) {
                timePicker.date = date
            }
        }
        
        datePicker.minimumDate = Date()
        //timePicker.setValue(UIColor.white, forKey: "textColor")
        formatter.dateFormat = "h:mm a"
        updateTime(date: timePicker.date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if event == nil {
            eventLabel.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Data Source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 1, section: 1) {
            return editingDate ? PICKER_HEIGHT_VISIBLE : PICKER_HEIGHT_HIDDEN
        } else if indexPath == IndexPath(row: 3, section: 1) {
            return editingTime ? PICKER_HEIGHT_VISIBLE : PICKER_HEIGHT_HIDDEN
        } else if indexPath == IndexPath(row: 0, section: 2) {
            return (event != nil) ? 44.0 : 0.0
        } else {
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = true
        cell.separatorInset = tableView.separatorInset
        
        if indexPath == IndexPath(row: 2, section: 1) && !editingTime {
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != IndexPath(row: 0, section: 0) {
            eventLabel.resignFirstResponder()
        }
        
        if indexPath == IndexPath(row: 0, section: 1) {
            editingTime = false
            editingDate = !editingDate
        } else if indexPath == IndexPath(row: 2, section: 1) {
            editingDate = false
            editingTime = !editingTime
        } else if indexPath == IndexPath(row: 0, section: 2) {
            deleteEventAlert()
        }
        
        dateDetailLabel.textColor = editingDate ? UIColor.selection : UIColor.black
        timeDetailLabel.textColor = editingTime ? UIColor.selection : UIColor.black
        
        tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .none)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Date/Time Picker Delegates
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        eventLabel.resignFirstResponder()
        
        formatter.dateFormat = "MMM d, yyyy"
        dateDetailLabel.text = formatter.string(from: sender.date)
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timePicker.date)
        if let hr = components.hour, let min = components.minute, let sec = components.second {
            if let date = Calendar.current.date(bySettingHour: hr, minute: min, second: sec, of: sender.date) {
                timePicker.date = date
                event?.date = date
            }
        }
    }
    
    @IBAction func changeTime(_ sender: UIDatePicker) {
        updateTime(date: sender.date)
    }
    
    func updateTime(date: Date) {
        eventLabel.resignFirstResponder()
        
        formatter.dateFormat = "h:mm a"
        
        // If midnight selected, provide custom label
        if Calendar.current.startOfDay(for: date).compare(date) == .orderedSame {
            timeDetailLabel.text = "Start of Day"
        } else {
            timeDetailLabel.text = formatter.string(from: date)
        }
        
        event?.date = date
    }
    
    // MARK: - Text Field Delegate
    @IBAction func updateName(_ sender: UITextField) {
        if let name = sender.text {
            event?.name = name
            doneButton.isEnabled = name.isEmpty ? false : true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func deleteEventAlert() {
        let message = "This counter will be permanently deleted."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Counter", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "deleteEvent", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        tableView.deselectRow(at: IndexPath(row: 0, section: 2), animated: true)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @IBAction func dismissSettings(_ sender: UIBarButtonItem) {
        self.eventLabel.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
}
