//
//  UIImage+rotated.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/28.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import GameplayKit
import UIKit

extension UIImage {
  func rotated(degree: Float) -> UIImage {
    let radian = CGFloat(GLKMathDegreesToRadians(degree))
    let rotatedSize = CGRect(origin: .zero, size: size)
      .applying(CGAffineTransform(rotationAngle: radian))
      .size

    UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
    defer {
      UIGraphicsEndImageContext()
    }

    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

    context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
    context.rotate(by: radian)
    context.translateBy(x: -size.width / 2.0, y: -size.height / 2.0)

    self.draw(at: .zero)

    guard let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
    return rotatedImage
  }
}
