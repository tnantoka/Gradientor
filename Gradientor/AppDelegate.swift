//
//  AppDelegate.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/17.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import ReSwift
import ChameleonFramework

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: nil
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setAppearance()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = MaterialDesign.backgroundColor

        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.isToolbarHidden = false
        navigationController.toolbar.clipsToBounds = true
        navigationController.toolbar.isTranslucent = false
        navigationController.navigationBar.isTranslucent = false
        navigationController.hidesNavigationBarHairline = true
        window?.rootViewController = navigationController

        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK: - Utilities

    private func setAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#F5F5F5")
        UINavigationBar.appearance().tintColor = UIColor(white: 0.0, alpha: 0.87)

        UIToolbar.appearance().barTintColor = UINavigationBar.appearance().barTintColor
        UIToolbar.appearance().tintColor = UINavigationBar.appearance().tintColor
    }
}
