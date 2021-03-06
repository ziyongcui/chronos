//
//  AppDelegate.swift
//  chronos
//
//  Created by Ziyong Cui on 6/1/20.
//  Copyright © 2020 Ziyong Cui. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //IF DATE IS NOT CURRENT DATE ON SAVED GENERATED SCHEDULE (IF ONE EXISTS) RETIRE IT FROM MEMORY
        if let retrievedSchedules = try?Data(contentsOf: URLs.idealSchedules){
            if let decodedSchedules = try?propertyListDecoder.decode(Array<IdealSchedule>.self, from: retrievedSchedules) {
                idealSchedules = decodedSchedules
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

