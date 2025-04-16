//
//  AppDelegate.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/17.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import ReSwift
import AdFooter

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: nil
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

        AdFooter.shared.adMobAdUnitId = Keys.adMobBannerUnitID
        AdFooter.shared.interstitial.adMobAdUnitId = Keys.adMobInterstitialUnitID
        #if DEBUG
//            window?.rootViewController = navigationController
            window?.rootViewController = AdFooter.shared.wrap(navigationController)
        #else
            window?.rootViewController = AdFooter.shared.wrap(navigationController)
        #endif

        window?.makeKeyAndVisible()

        return true
    }

    // MARK: - Utilities

    private func setAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#F5F5F5")
        UINavigationBar.appearance().tintColor = MaterialDesign.flatBlueColor
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: UINavigationBar.appearance().tintColor
        ])

        UIToolbar.appearance().barTintColor = UINavigationBar.appearance().barTintColor
        UIToolbar.appearance().tintColor = UINavigationBar.appearance().tintColor

        if #available(iOS 15.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor(hexString: "#F5F5F5")
            navAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: MaterialDesign.flatBlueColor]

            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

            let toolbarAppearance = UIToolbarAppearance()
            toolbarAppearance.configureWithOpaqueBackground()
            toolbarAppearance.backgroundColor = navAppearance.backgroundColor

            UIToolbar.appearance().standardAppearance = toolbarAppearance
            UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
