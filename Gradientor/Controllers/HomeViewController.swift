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

class HomeViewController: UIViewController {

    private let bag = DisposeBag()
    private let store = RxStore<AppState>(store: mainStore)

    private var gradient = Gradient()

    lazy private var editItem: UIBarButtonItem = {
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        editItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.editDidTap()
            })
            .addDisposableTo(self.bag)
        return editItem
    }()
    lazy private var clearItem: UIBarButtonItem = {
        let clearItem = UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""),
                                        style: .plain, target: nil, action: nil)
        clearItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.clearDidTap()
            })
            .addDisposableTo(self.bag)
        return clearItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Gradientor", comment: "")
        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = editItem
        toolbarItems = [clearItem]

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
        view.layer.sublayers?.first?.removeFromSuperlayer()
        gradient.colors = colors
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient.layer)
    }

    private func updateUI(colors: [UIColor]) {
        clearItem.isEnabled = colors.count > 0
    }

    private func randomColor() -> UIColor {
        let random = GKRandomSource()
        let color = UIColor(
            red: CGFloat(random.nextUniform()),
            green: CGFloat(random.nextUniform()),
            blue: CGFloat(random.nextUniform()),
            alpha: 1.0
        )
        return color
    }

    // MARK - Actions

    private func editDidTap() {
        let editViewController = EditViewController()
        navigationController?.pushViewController(editViewController, animated: true)
    }

    @objc private func clearDidTap() {
        mainStore.dispatch(AppAction.clearColors)
    }
}
