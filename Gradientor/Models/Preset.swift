//
//  Preset.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/27.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

struct Preset {
    static let names = [
        NSLocalizedString("Twitter", comment: ""),
        NSLocalizedString("Facebook", comment: ""),
        NSLocalizedString("iPhone 5.5-inch", comment: ""),
        NSLocalizedString("iPhone 4.7-inch", comment: ""),
        NSLocalizedString("iPhone 4-inch", comment: "")
    ]
    static let sizes = [
        CGSize(width: 1500.0, height: 500.0),
        CGSize(width: 851.0, height: 315.0),
        CGSize(width: 1080.0, height: 1920.0),
        CGSize(width: 750.0, height: 1334.0),
        CGSize(width: 640.0, height: 1136.0)
    ]
}
