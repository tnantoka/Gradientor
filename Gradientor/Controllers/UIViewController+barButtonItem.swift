//
//  UIViewController+barButtonItem.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/28.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import RxSwift
import UIKit

extension UIViewController {
  func barButtomItem(
    systemItem: UIBarButtonItem.SystemItem, bag: DisposeBag,
    didTap: @escaping () -> Void
  ) -> UIBarButtonItem {
    let item = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
    return barButtomItem(item: item, bag: bag, didTap: didTap)
  }

  func barButtomItem(
    title: String, bag: DisposeBag,
    didTap: @escaping () -> Void
  ) -> UIBarButtonItem {
    let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
    return barButtomItem(item: item, bag: bag, didTap: didTap)
  }

  func barButtomItem(
    systemName: String, bag: DisposeBag,
    didTap: @escaping () -> Void
  ) -> UIBarButtonItem {
    let config = UIImage.SymbolConfiguration(pointSize: 18.0, weight: .regular)
    let image = UIImage(systemName: systemName, withConfiguration: config)

    let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
    return barButtomItem(item: item, bag: bag, didTap: didTap)
  }

  private func barButtomItem(
    item: UIBarButtonItem, bag: DisposeBag,
    didTap: @escaping () -> Void
  ) -> UIBarButtonItem {
    item.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { _ in
        didTap()
      })
      .addDisposableTo(bag)
    return item
  }
}
