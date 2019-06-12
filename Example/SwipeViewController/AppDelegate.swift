//
//  AppDelegate.swift
//  SwipeViewController
//
//  Created by fortmarek on 03/18/2016.
//  Copyright (c) 2016 fortmarek. All rights reserved.
//

import UIKit
import SwipeViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application:UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let swipeViewController = ViewController()

        let VC1 = TestViewController()
        VC1.view.backgroundColor = UIColor(red: 0.19, green: 0.36, blue: 0.60, alpha: 1.0)
        VC1.title = "Recent"
        let VC2 = UIViewController()
        VC2.view.backgroundColor = UIColor(red: 0.70, green: 0.23, blue: 0.92, alpha: 1.0)
        VC2.title = "All"
        let VC3 = UIViewController()
        VC3.view.backgroundColor = UIColor(red: 0.17, green: 0.70, blue: 0.27, alpha: 1.0)
        VC3.title = "Trending"
        swipeViewController.pages = [VC1, VC2, VC3]
        swipeViewController.startIndex = 0
        swipeViewController.selectionBarWidth = 80
        swipeViewController.selectionBarHeight = 3
        swipeViewController.selectionBarColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
        swipeViewController.selectedButtonColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
        swipeViewController.equalSpaces = false

        self.window?.rootViewController = swipeViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

