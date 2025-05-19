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
    let image = UIImage(systemName: systemName)
    return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
  }
}
