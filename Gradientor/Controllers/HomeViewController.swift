//
//  HomeViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/17.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import IoniconsKit
import RFAboutView_Swift
import ChameleonFramework

class HomeViewController: UIViewController {

    private let bag = DisposeBag()
    private let store = RxStore<AppState>(store: mainStore)

    private var gradient = Gradient()

    lazy private var infoItem: UIBarButtonItem = {
        let infoItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        infoItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        infoItem.title = String.ionicon(with: .information)

        infoItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.infoDidTap()
            })
            .addDisposableTo(self.bag)
        return infoItem
    }()
    lazy private var editItem: UIBarButtonItem = {
        let editItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        editItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        editItem.title = String.ionicon(with: .edit)

        editItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.editDidTap()
            })
            .addDisposableTo(self.bag)
        return editItem
    }()

    lazy private var clearItem: UIBarButtonItem = {
        let clearItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)

        clearItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.clearDidTap()
            })
            .addDisposableTo(self.bag)
        return clearItem
    }()
    lazy private var refreshItem: UIBarButtonItem = {
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)

        refreshItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshDidTap()
            })
            .addDisposableTo(self.bag)
        return refreshItem
    }()
    lazy private var exportItem: UIBarButtonItem = {
        let exportItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)

        exportItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.exportDidTap()
            })
            .addDisposableTo(self.bag)
        return exportItem
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
    }

    // MARK - Utilities

    private func updateGradient(colors: [UIColor]) {
        view.layer.sublayers?.forEach { sublayer in
            if sublayer.isKind(of: LinerLayer.self) || sublayer.isKind(of: RadialLayer.self) {
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
            title: NSLocalizedString(title, comment: ""),
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
                title: NSLocalizedString(actionTitle, comment: ""),
                style: .destructive
            ) { _ in
                didConfirm()
            }
        )

        present(alertViewController, animated: true, completion: nil)
    }

    // MARK - Actions

    private func editDidTap() {
        let editViewController = EditViewController()
        navigationController?.pushViewController(editViewController, animated: true)
    }

    private func infoDidTap() {
        let aboutViewController = RFAboutViewController()

        aboutViewController.copyrightHolderName = "tnantoka"
//        aboutViewController.contactEmail = "tnantoka+gradientor@bornneet.com"
//        aboutViewController.contactEmailTitle = NSLocalizedString("Contact", comment: "")
        aboutViewController.websiteURL = URL(string: "http://gradientor.com/")!
        aboutViewController.websiteURLTitle = aboutViewController.websiteURL!.absoluteString

        aboutViewController.closeButtonAsImage = false
        aboutViewController.headerBorderColor = .clear
        aboutViewController.tableViewSeparatorColor = .clear
        aboutViewController.navigationBarTintColor = UINavigationBar.appearance().tintColor
        aboutViewController.navigationBarBarTintColor = UINavigationBar.appearance().barTintColor
        aboutViewController.backgroundColor = MaterialDesign.backgroundColor

        let aboutNavigationController = UINavigationController(rootViewController: aboutViewController)
        aboutNavigationController.navigationBar.isTranslucent = false
        aboutNavigationController.hidesNavigationBarHairline = true

        present(aboutNavigationController, animated: true, completion: nil)
    }

    private func clearDidTap() {
        confirm(
            title: "Delete All Colors",
            actionTitle: "Delete"
        ) { [weak self] in
            self?.clear()
        }
    }

    private func refreshDidTap() {
        confirm(
            title: "Recreate Colors",
            actionTitle: "OK"
        ) { [weak self] in
            self?.refresh()
        }
    }

    private func exportDidTap() {
        let exportViewController = ExportViewController()

        exportViewController.didClose = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        let exportNavigationController = UINavigationController(rootViewController: exportViewController)
        exportNavigationController.navigationBar.isTranslucent = false
        exportNavigationController.hidesNavigationBarHairline = true

        present(exportNavigationController, animated: true, completion: nil)
    }
}
