//
//  ColorsViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/18.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import RxSwift
import IGColorPicker
import SnapKit

class ColorsViewController: UIViewController {

    let bag = DisposeBag()

    fileprivate let selectedColorsSubject = PublishSubject<UIColor>()
    var selectedColors: Observable<UIColor> {
        return selectedColorsSubject.asObservable()
    }

    var colorPickerView: ColorPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white

        colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.isSelectedColorTappable = false
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
