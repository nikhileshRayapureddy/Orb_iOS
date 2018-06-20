//
//  AppDelegate.swift
//  Orb
//
//  Created by Nikhilesh on 18/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
import CoreData
import CoreTelephony
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isServerReachable : Bool = false
    var reachability: Reachability?
    var photos: PHFetchResult<PHAsset>!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.backgroundColor = UIColor.white
        IQKeyboardManager.sharedManager().enable = true

        self.setupReachability(hostName: "", useClosures: false)
        self.startNotifier()
        print("reachable = ",isServerReachable)
        isServerReachable = (reachability?.isReachable)!
        print("reachable after= ",isServerReachable)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataAccessLayer().saveContext()
    }
    // MARK: - Reachability
    
    func setupReachability(hostName: String?, useClosures: Bool) {
        
        let reachabil = hostName == "" ? Reachability() : Reachability(hostname: hostName!)
        reachability = reachabil
        if useClosures {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    self.isServerReachable = true
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    self.isServerReachable = false
                }
            }
            print("reachable setup = ",isServerReachable)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            isServerReachable = true
            NotificationCenter.default.post(name: Notification.Name("ServerActive"), object: nil, userInfo: nil)

        } else {
            isServerReachable = false
        }
    }
    
    deinit {
        stopNotifier()
    }

}

