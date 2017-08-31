//
//  DataViewController.swift
//  ZeroSeconds
//
//  Created by Elliot Barer on 2017-08-24.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit
import GLKit

class DataViewController: UIViewController {

    // MARK: - Properties
    var event: Event?
    
    // MARK: - Graphics
    let myShape = CAShapeLayer()
    let gradient = CAGradientLayer()
    let cornerRadius: CGFloat = 14.0
    
    // MARK: - Outlets
    @IBOutlet var counterFrame: UIView!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var daysStack: UIStackView!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var hrsStack: UIStackView!
    @IBOutlet var hrsLabel: UILabel!
    @IBOutlet var minStack: UIStackView!
    @IBOutlet var minLabel: UILabel!
    @IBOutlet var secStack: UIStackView!
    @IBOutlet var secLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counterFrame.backgroundColor = .clear
        counterFrame.layer.cornerRadius = cornerRadius
        counterFrame.layer.insertSublayer(gradient, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        styleFrame()
        updateTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        removeButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Draw methods
    
    func styleFrame() {
        // Configure gradient
        let colors = [
            UIColor(white: 0.20, alpha: 1).cgColor,
            UIColor(white: 0.33, alpha: 1).cgColor
        ]
        
        gradient.colors = colors
        gradient.locations = [0.2, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = counterFrame.bounds
        gradient.cornerRadius = cornerRadius
        
        // Configure shadow
        let width = counterFrame.bounds.width - 10
        let height: CGFloat = counterFrame.bounds.height - 10
        let shadowShape = CGRect(x: 0, y: 0, width: width, height: height)
        let shadowPath = UIBezierPath(roundedRect: shadowShape, cornerRadius: cornerRadius).cgPath

        counterFrame.layer.shadowPath = shadowPath
        counterFrame.layer.shadowColor = UIColor.black.cgColor
        counterFrame.layer.shadowOpacity = 0.45
        counterFrame.layer.shadowOffset = CGSize(width: 5, height: 20)
        counterFrame.layer.shadowRadius = 20
    }
    
    @objc func updateTime() {
        if let event = event {
            var rankColored = false
            var fontSize: CGFloat = 40.0
            eventLabel.text = event.name
            
            if let days = event.difference[.day] {
                daysStack.isHidden = false
                daysLabel.text = String(days)
                daysLabel.textColor = UIColor.selection
                daysLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
                rankColored = true
            } else {
                daysStack.isHidden = true
                fontSize = 50.0
            }
            
            if let hrs = event.difference[.hour] {
                hrsStack.isHidden = false
                hrsLabel.text = String(hrs)
                hrsLabel.textColor = rankColored ? UIColor.white : UIColor.selection
                hrsLabel.font = UIFont.systemFont(ofSize: fontSize,
                                                  weight: rankColored ? .ultraLight : .light)
                rankColored = true
            } else {
                if event.difference[.day] == nil {
                    hrsStack.isHidden = true
                    fontSize = 60.0
                }
            }

            if let min = event.difference[.minute] {
                minStack.isHidden = false
                minLabel.text = String(min)
                minLabel.textColor = rankColored ? UIColor.white : UIColor.selection
                minLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
                rankColored = true
            } else {
                if event.difference[.day] == nil && event.difference[.hour] == nil {
                    minStack.isHidden = true
                    fontSize = 90.0
                }
            }
            
            secLabel.text = "\(event.difference[.second] ?? 0)"
            secLabel.textColor = rankColored ? UIColor.white : UIColor.selection
            secLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
            
            // Show remove button for expired counters
            removeButton.isHidden = event.difference[.second] != nil
        }
    }
    
    @objc func drawSeconds() {
        let components = Calendar.current.dateComponents([.second, .nanosecond], from: Date())
        guard let sec = components.second, let ns = components.nanosecond else {
            return
        }
        
        let ms = (Float(sec) * 1E3) + (Float(ns) / 1E6)
        let trueAngle = (ms / 1000.0) * 180
        let angle = trueAngle.truncatingRemainder(dividingBy: 180.0)
        let origin = CGPoint(x: counterFrame.frame.width / 2, y: counterFrame.frame.height / 2)
        let radius = counterFrame.frame.width / 2 - 40
        let path = UIBezierPath(arcCenter: origin,
                                radius: radius,
                                startAngle: CGFloat(GLKMathDegreesToRadians(0)),
                                endAngle: CGFloat(GLKMathDegreesToRadians(angle)),
                                clockwise: true)
        
        myShape.path = path.cgPath
        myShape.lineWidth = 20.0
        myShape.lineCap = kCALineCapRound
        myShape.strokeColor = UIColor.selection.cgColor
        myShape.fillColor = UIColor.clear.cgColor
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCounter" {
            if let vc = (segue.destination as? UINavigationController)?.childViewControllers.first as? SettingsTableViewController {
                vc.event = self.event
            }
        }
    }
    
}

