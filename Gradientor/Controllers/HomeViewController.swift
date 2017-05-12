//
//  HomeViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/17.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit
import GameplayKit

import RxSwift
import RxCocoa
import IoniconsKit
import RFAboutView_Swift
import ChameleonFramework
import AdFooter

class HomeViewController: UIViewController {

    private let bag = DisposeBag()
    private let store = RxStore<AppState>(store: mainStore)

    internal var gradient = Gradient()

    lazy internal var infoItem: UIBarButtonItem = {
        self.barButtomItem(icon: .information, bag: self.bag) { [weak self] _ in
            self?.infoDidTap()
        }
    }()
    lazy internal var editItem: UIBarButtonItem = {
        self.barButtomItem(icon: .edit, bag: self.bag) { [weak self] _ in
            self?.editDidTap()
        }
    }()

    lazy internal var clearItem: UIBarButtonItem = {
        self.barButtomItem(systemItem: .trash, bag: self.bag) { [weak self] _ in
            self?.clearDidTap()
        }
    }()
    lazy internal var refreshItem: UIBarButtonItem = {
        self.barButtomItem(systemItem: .refresh, bag: self.bag) { [weak self] _ in
            self?.refreshDidTap()
        }
    }()
    lazy internal var exportItem: UIBarButtonItem = {
        self.barButtomItem(systemItem: .action, bag: self.bag) { [weak self] _ in
            self?.exportDidTap()
        }
    }()
    private let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Gradientor", comment: "")
        view.backgroundColor = MaterialDesign.backgroundColor

        navigationItem.leftBarButtonItem = infoItem
        navigationItem.rightBarButtonItem = editItem
        toolbarItems = [flexibleItem, clearItem, flexibleItem, refreshItem, flexibleItem, exportItem, flexibleItem]

        let colors = store.state.asDriver()
            .map { $0.colors }

        colors.drive(onNext: { [weak self] colors in
                self?.updateGradient(colors: colors)
            })
            .addDisposableTo(bag)
        colors.drive(onNext: { [weak self] colors in
                self?.updateUI(colors: colors)
            })
            .addDisposableTo(bag)

        refresh()
        #if DEBUG
//            setIconColors(); let fixme = ""
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if DEBUG
            print("RxSwift Resources: \(RxSwift.Resources.total)")
        #endif
    }

    // MARK - Utilities

    internal func setIconColors() {
        mainStore.dispatch(AppAction.clearColors)
        mainStore.dispatch(AppAction.addColor(FlatBlue()))
        mainStore.dispatch(AppAction.addColor(FlatPowderBlueDark()))
        mainStore.dispatch(AppAction.addColor(FlatPowderBlue()))
    }

    private func updateGradient(colors: [UIColor]) {
        view.layer.sublayers?.forEach { sublayer in
            if sublayer.isKind(of: GradientLayer.self) {
                sublayer.removeFromSuperlayer()
            }
        }

        gradient.direction = mainStore.state.direction
        gradient.colors = colors
        gradient.frame = view.bounds

        view.layer.addSublayer(gradient.layer)
    }

    private func updateUI(colors: [UIColor]) {
        clearItem.isEnabled = colors.count > 1
        exportItem.isEnabled = colors.count > 1
    }

    private func clear() {
        mainStore.dispatch(AppAction.clearColors)
    }

    private func refresh() {
        clear()
        mainStore.dispatch(AppAction.addRandomColor)
        mainStore.dispatch(AppAction.addRandomColor)
    }

    private func confirm(title: String, actionTitle: String, didConfirm: @escaping () -> Void) {
        let alertViewController = UIAlertController(
            title: title,
            message: NSLocalizedString("Are you sure?", comment: ""),
            preferredStyle: .alert
        )

        alertViewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        alertViewController.addAction(
            UIAlertAction(
                title: actionTitle,
                style: .destructive
            ) { _ in
                didConfirm()
            }
        )

        present(alertViewController, animated: true, completion: nil)
    }

    private func showInterstitial() {
        #if DEBUG
            let threshold = 1
        #else
            let threshold = GKRandomDistribution(lowestValue: 3, highestValue: 5).nextInt()
        #endif
        if mainStore.state.exportCount % threshold == 0 {
            AdFooter.shared.interstitial.present(for: self)
        }
    }

    // MARK - Actions

    private func editDidTap() {
        let editViewController = EditViewController()
        navigationController?.pushViewController(editViewController, animated: true)
    }

    private func infoDidTap() {
        let aboutViewController = RFAboutViewController()

        aboutViewController.title = NSLocalizedString("About", comment: "")
        aboutViewController.copyrightHolderName = "tnantoka"
        aboutViewController.websiteURL = URL(string: "http://gradientor.com/")!
        aboutViewController.websiteURLTitle = aboutViewController.websiteURL!.absoluteString

        aboutViewController.closeButtonAsImage = false
        aboutViewController.headerBorderColor = .clear
        aboutViewController.tableViewSeparatorColor = .clear
        aboutViewController.navigationBarTintColor = UINavigationBar.appearance().tintColor
        aboutViewController.navigationBarBarTintColor = UINavigationBar.appearance().barTintColor
        aboutViewController.navigationBarTitleTextColor = UINavigationBar.appearance().tintColor
        aboutViewController.backgroundColor = MaterialDesign.backgroundColor

        let aboutNavigationController = UINavigationController(rootViewController: aboutViewController)
        aboutNavigationController.navigationBar.isTranslucent = false
        aboutNavigationController.hidesNavigationBarHairline = true

        present(aboutNavigationController, animated: true, completion: nil)
    }

    private func clearDidTap() {
        confirm(
            title: NSLocalizedString("Delete All Colors", comment: ""),
            actionTitle: NSLocalizedString("Delete", comment: "")
        ) { [weak self] in
            self?.clear()
        }
    }

    private func refreshDidTap() {
        confirm(
            title: NSLocalizedString("Recreate Colors", comment: ""),
            actionTitle: NSLocalizedString("OK", comment: "")
        ) { [weak self] in
            self?.refresh()
        }
    }

    private func exportDidTap() {
        let exportViewController = ExportViewController()

        exportViewController.didClose = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.showInterstitial()
        }

        let exportNavigationController = UINavigationController(rootViewController: exportViewController)
        exportNavigationController.navigationBar.isTranslucent = false
        exportNavigationController.hidesNavigationBarHairline = true

        present(exportNavigationController, animated: true, completion: nil)
    }
}
