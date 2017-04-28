//
//  UIViewController+barButtonItem.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/28.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import RxSwift
import IoniconsKit

extension UIViewController {
    func barButtomItem(systemItem: UIBarButtonSystemItem, bag: DisposeBag,
                       didTap: @escaping () -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        return barButtomItem(item: item, bag: bag, didTap: didTap)
    }

    func barButtomItem(title: String, bag: DisposeBag,
                       didTap: @escaping () -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        return barButtomItem(item: item, bag: bag, didTap: didTap)
    }

    func barButtomItem(icon: Ionicons, bag: DisposeBag,
                       didTap: @escaping () -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        item.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
            ], for: .normal)
        item.title = String.ionicon(with: icon)
        return barButtomItem(item: item, bag: bag, didTap: didTap)
    }

    private func barButtomItem(item: UIBarButtonItem, bag: DisposeBag,
                               didTap: @escaping () -> Void) -> UIBarButtonItem {
        item.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                didTap()
            })
            .addDisposableTo(bag)
        return item
    }
}
