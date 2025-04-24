//
//  UIViewController+barButtonItem.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/28.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

extension UIViewController {
  func barButtonItem(
    systemName: String,
    target: Any,
    action: Selector
  ) -> UIBarButtonItem {
    let config = UIImage.SymbolConfiguration(pointSize: 18.0, weight: .regular)
    let image = UIImage(systemName: systemName, withConfiguration: config)
    return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
  }
}
