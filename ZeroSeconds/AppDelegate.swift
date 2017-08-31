//
//  AppDelegate.swift
//  ZeroSeconds
//
//  Created by Elliot Barer on 2017-08-24.
//  Copyright © 2017 ebarer. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var _modelController: ModelController? = nil
    var modelController: ModelController {
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        
        modelController.load()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let saved = modelController.save()
        NSLog("Events saved on [enter background] ? %@", saved ? "true" : "false")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let saved = modelController.save()
        NSLog("Events saved on [terminate] ? %@", saved ? "true" : "false")
    }


}

