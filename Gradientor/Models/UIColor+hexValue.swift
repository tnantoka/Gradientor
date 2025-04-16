//
//  UIColor+hexValue.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2025/04/15.
//  Copyright © 2025 tnantoka. All rights reserved.
//

import UIKit

extension UIColor {
  // https://github.com/vicc/chameleon/blob/6dd284bde21ea2e7f9fd89bc36f40df16e16369d/Pod/Classes/Objective-C/UIColor%2BChameleon.m#L785
  func hexValue() -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0

    self.getRed(&r, green: &g, blue: &b, alpha: &a)

    let redValue = Int(r * 255.0)
    let greenValue = Int(g * 255.0)
    let blueValue = Int(b * 255.0)

    return String(format: "#%02X%02X%02X", redValue, greenValue, blueValue)
  }
}
