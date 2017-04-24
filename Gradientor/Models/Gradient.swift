//
//  Gradient.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

struct Gradient {
    var layer = CAGradientLayer()

    var colors = [UIColor]() {
        didSet {
            layer.colors = colors.map { $0.cgColor }
        }
    }
    var frame = CGRect.zero {
        didSet {
            layer.frame = frame
        }
    }
}
