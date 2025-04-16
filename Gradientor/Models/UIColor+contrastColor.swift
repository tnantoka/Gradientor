//
//  UIColor+contrastColor.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2025/04/15.
//  Copyright © 2025 tnantoka. All rights reserved.
//

import UIKit

extension UIColor {
  // https://github.com/vicc/chameleon/blob/6dd284bde21ea2e7f9fd89bc36f40df16e16369d/Pod/Classes/Objective-C/UIColor%2BChameleon.m#L423
  func contrastColor() -> UIColor {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    self.getRed(&r, green: &g, blue: &b, alpha: &a)

    let luminance = r * 0.2126 + g * 0.7152 + b * 0.0722

    let dark = UIColor(hue: 0, saturation: 0, brightness: 0.15, alpha: 1.0)
    let light = UIColor(hue: 192 / 360, saturation: 0.02, brightness: 0.95, alpha: 1.0)
    return luminance > 0.6 ? dark : light
  }
}
