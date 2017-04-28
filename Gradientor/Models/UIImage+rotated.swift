//
//  UIImage+rotated.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/28.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit
import GameplayKit

extension UIImage {
    func rotated(degree: Float) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)

        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: 1.0, y: -1.0)

        let radian = CGFloat(GLKMathDegreesToRadians(degree))
        context.rotate(by: radian)

        guard let cgImage = cgImage else { return UIImage() }
        context.draw(cgImage, in: CGRect(origin: CGPoint(x: -center.x, y: -center.y), size: size))

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        return image
    }
}
