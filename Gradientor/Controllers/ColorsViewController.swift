//
//  ColorsViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/18.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit
import GameplayKit

import RxSwift
import IGColorPicker
import SnapKit

class ColorsViewController: UIViewController {

    let bag = DisposeBag()

    fileprivate let selectedColorsSubject = PublishSubject<UIColor>()
    var selectedColors: Observable<UIColor> {
        return selectedColorsSubject.asObservable()
    }

    private var randomColor: UIColor {
        let random = GKRandomSource()
        let randomColor = UIColor(
            red: CGFloat(random.nextUniform()),
            green: CGFloat(random.nextUniform()),
            blue: CGFloat(random.nextUniform()),
            alpha: 1.0
        )
        return randomColor
    }

    lazy private var randomItem: UIBarButtonItem = {
        let randomItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        randomItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
            ], for: .normal)
        randomItem.title = String.ionicon(with: .shuffle)

        randomItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let color = self?.randomColor else { return }
                mainStore.dispatch(AppAction.addColor(color))
            })
            .addDisposableTo(self.bag)
        return randomItem
    }()
    lazy private var imageItem: UIBarButtonItem = {
        let imageItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        imageItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
            ], for: .normal)
        imageItem.title = String.ionicon(with: .image)

        return imageItem
    }()
    lazy private var rgbItem: UIBarButtonItem = {
        let rgbItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        rgbItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
            ], for: .normal)
        rgbItem.title = String.ionicon(with: .pound)

        rgbItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.rgbDidTap()
            })
            .addDisposableTo(self.bag)
        return rgbItem
    }()
    private let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    lazy private var colorPickerView: ColorPickerView = {
        let colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.isSelectedColorTappable = false
        colorPickerView.colors = Gradient.flatColors
        return colorPickerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white

        toolbarItems = [flexibleItem, randomItem, flexibleItem, imageItem, flexibleItem, rgbItem, flexibleItem]

        view.addSubview(colorPickerView)
        colorPickerView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.right.equalTo(view)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        selectedColorsSubject.onCompleted()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK - Actions

    private func rgbDidTap() {
        let alertViewController = UIAlertController(
            title: NSLocalizedString("Add Color", comment: ""),
            message: NSLocalizedString("Enter a color code.", comment: ""),
            preferredStyle: .alert
        )

        alertViewController.addTextField { textField in
            textField.placeholder = "RRGGBB"
        }

        alertViewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        alertViewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Add", comment: ""),
                style: .default
            ) { _ in
                guard let rgb = alertViewController.textFields?.first?.text else { return }
                let code = rgb.replacingOccurrences(of: "#", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard let color = UIColor(hexString: code) else { return }
                mainStore.dispatch(AppAction.addColor(color))
            }
        )

        present(alertViewController, animated: true, completion: nil)
    }
}

extension ColorsViewController: ColorPickerViewDelegate {
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        let color = colorPickerView.colors[indexPath.item]
        selectedColorsSubject.onNext(color)
    }
}

extension ColorsViewController: ColorPickerViewDelegateFlowLayout {

    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55.0, height: 55.0)
    }

    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }

    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

    func colorPickerView(_ colorPickerView: ColorPickerView,
                         minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}
