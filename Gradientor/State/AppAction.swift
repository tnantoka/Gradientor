//
//  AppAction.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Foundation

import ReSwift

enum AppAction: Action {
    case addColor(UIColor)
    case addRandomColor
    case addColors([UIColor])
    case clearColors
    case moveColor(from: Int, to: Int)
    case deleteColor(Int)

    case setDirection(Gradient.Direction)
}
