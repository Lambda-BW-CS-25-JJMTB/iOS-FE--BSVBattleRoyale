//
//  AppDelegate.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {       
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.window?.rootViewController = initialViewController
        //self.window?.makeKeyAndVisible()
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

