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
import Keys
import AdFooter

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

        AdFooter.shared.adMobAdUnitId = GradientorKeys().adMobBannerUnitID
        AdFooter.shared.interstitial.adMobAdUnitId = GradientorKeys().adMobInterstitialUnitID
        #if DEBUG
            window?.rootViewController = navigationController
//            window?.rootViewController = AdFooter.shared.wrap(navigationController)
        #else
            window?.rootViewController = AdFooter.shared.wrap(navigationController)
        #endif

        window?.makeKeyAndVisible()

        AdFooter.shared.interstitial.load()

        return true
    }

    // MARK: - Utilities

    private func setAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#F5F5F5")
        UINavigationBar.appearance().tintColor = FlatBlue()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UINavigationBar.appearance().tintColor
        ]

        UIToolbar.appearance().barTintColor = UINavigationBar.appearance().barTintColor
        UIToolbar.appearance().tintColor = UINavigationBar.appearance().tintColor
    }
}
