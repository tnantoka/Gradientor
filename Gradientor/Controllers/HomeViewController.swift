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
    lazy private var exportItem: UIBarButtonItem = {
        let exportItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)

        return exportItem
    }()
    private let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Gradientor", comment: "")
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = infoItem
        navigationItem.rightBarButtonItem = editItem
        toolbarItems = [flexibleItem, clearItem, flexibleItem, exportItem, flexibleItem]

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // MARK - Actions

    private func editDidTap() {
        let editViewController = EditViewController()
        navigationController?.pushViewController(editViewController, animated: true)
    }

    private func infoDidTap() {
        let aboutViewController = RFAboutViewController()
        aboutViewController.closeButtonAsImage = false
        aboutViewController.copyrightHolderName = "tnantoka"
//        aboutViewController.contactEmail = "tnantoka+gradientor@bornneet.com"
//        aboutViewController.contactEmailTitle = NSLocalizedString("Contact", comment: "")
        aboutViewController.websiteURL = URL(string: "http://gradientor.com/")!
        aboutViewController.websiteURLTitle = aboutViewController.websiteURL!.absoluteString

        let aboutNavigationController = UINavigationController(rootViewController: aboutViewController)
        aboutNavigationController.navigationBar.isTranslucent = false
        aboutNavigationController.hidesNavigationBarHairline = true

        present(aboutNavigationController, animated: true, completion: nil)
    }

    private func clearDidTap() {
        let alertViewController = UIAlertController(
            title: NSLocalizedString("Delete All Colors", comment: ""),
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
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive
            ) { _ in
                mainStore.dispatch(AppAction.clearColors)
            }
        )

        present(alertViewController, animated: true, completion: nil)
    }
}
