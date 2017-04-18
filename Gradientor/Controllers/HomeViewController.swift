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

class HomeViewController: UIViewController {

    private let bag = DisposeBag()
    private let colors = Variable<[UIColor]>([])
    private let gradientLayer = CAGradientLayer()

    private var addItem: UIBarButtonItem!
    private var clearItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        navigationController?.isToolbarHidden = false

        view.layer.addSublayer(gradientLayer)

        addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDidTap))
        clearItem = UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""), style: .plain, target: self, action: #selector(clearDidTap))

        navigationItem.rightBarButtonItem = addItem
        toolbarItems = [clearItem]

        colors.asObservable()
            .subscribe(onNext: { [weak self] colors in
                guard let view = self?.view else { fatalError() }
                self?.gradientLayer.colors = colors.map { $0.cgColor }
                self?.gradientLayer.frame = view.bounds
            }).addDisposableTo(bag)
        colors.asObservable()
            .subscribe(onNext: { [weak self] colors in
                self?.updateUI(colors: colors)
            }).addDisposableTo(bag)

        clear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK - Utilities

    private func updateUI(colors: [UIColor]) {
        clearItem.isEnabled = colors.count > 0
        title = colors.isEmpty ? NSLocalizedString("Gradientor", comment: "") : NSLocalizedString("\(colors.count) colors", comment: "")
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

    private func clear() {
        colors.value = [
//            randomColor(),
//            randomColor(),
        ]
    }

    // MARK - Actions

    @objc private func addDidTap(sender: Any) {
        // colors.value.append(randomColor())
        let colorsViewController = ColorsViewController()
        colorsViewController.selectedColors
            .subscribe(onNext: { [weak self] newColor in
                self?.colors.value.append(newColor)
            })
            .addDisposableTo(colorsViewController.bag)

        navigationController?.pushViewController(colorsViewController, animated: true)
    }

    @objc private func clearDidTap(sender: Any) {
        clear()
    }
}
