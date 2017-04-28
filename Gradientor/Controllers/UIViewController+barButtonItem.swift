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
    func barButtomItem(
        systemItem: UIBarButtonSystemItem? = nil,
        title: String? = nil,
        icon: Ionicons? = nil,
        bag: DisposeBag,
        didTap: @escaping () -> Void
        ) -> UIBarButtonItem {
        let item: UIBarButtonItem

        if let systemItem = systemItem {
            item = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        } else if let title = title {
            item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        } else if let icon = icon {
            item = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
            item.setTitleTextAttributes([
                NSFontAttributeName: UIFont.ionicon(of: 22.0)
                ], for: .normal)
            item.title = String.ionicon(with: icon)
        } else {
            item = UIBarButtonItem()
        }

        item.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                didTap()
            })
            .addDisposableTo(bag)
        return item
    }
}
