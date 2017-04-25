//
//  AppState.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Foundation
import GameplayKit

import ReSwift

struct AppState: StateType {
    var colors: [UIColor] = [
        AppState.randomColor,
        AppState.randomColor
    ]
    var direction = Gradient.Direction.horizontal

    static var randomColor: UIColor {
        let random = GKRandomSource()
        let randomColor = UIColor(
            red: CGFloat(random.nextUniform()),
            green: CGFloat(random.nextUniform()),
            blue: CGFloat(random.nextUniform()),
            alpha: 1.0
        )
        return randomColor
    }
}
