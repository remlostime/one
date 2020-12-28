//
//  AppDelegate.swift
//  one
//
//  Created by Kai Chen on 12/19/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let AppID = "one4ig_appid_1234567890"
    let ClientKey = "one4ig_masterkey_1234567890"
    let Server = "http://one4ig.herokuapp.com/parse"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // TODO(kai) - Clean up the code
        // Configuration of using Parse code in Heroku
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            // accessing Heroku App via id & keys
            ParseMutableClientConfiguration.applicationId = self.AppID
            ParseMutableClientConfiguration.clientKey = self.ClientKey
            ParseMutableClientConfiguration.server = self.Server
        }

        Parse.initialize(with: parseConfig)

        let username = UserDefaults.standard.string(forKey: User.id.rawValue)
        login(withUserName: username)

        DDLog.add(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance()) // ASL = Apple System Logs

        DDTTYLogger.sharedInstance().setForegroundColor(.red, backgroundColor: .black, for: .debug)

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        DDLogDebug("CK")

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
    }

    // MARK: Helpers
    func login(withUserName username: String?) {
        if let _ = username {
            // Store logged user in userDefaults
            UserDefaults.standard.set(username, forKey: User.id.rawValue)
            UserDefaults.standard.synchronize()

            let storyboard = UIStoryboard(name: "Main",
                                          bundle: nil)
            let oneTabBarVC = storyboard.instantiateViewController(withIdentifier: "oneTabBar") as? UITabBarController
            window?.rootViewController = oneTabBarVC
        }
    }
}

