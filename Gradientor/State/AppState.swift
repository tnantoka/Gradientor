//
//  AppState.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Foundation
import GameplayKit

final class AppState {
  static let shared = AppState()

  private init() {}

  var colors = [UIColor]()
  var direction = Gradient.Direction.horizontal
  var exportSize = CGSize(
    width: UIScreen.main.bounds.size.width * UIScreen.main.scale,
    height: UIScreen.main.bounds.size.height * UIScreen.main.scale
  )
  var isExportImage = true
  var isExportText = false
  var exportCount = 0

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

  func moveColor(from: Int, to: Int) {
    let color = colors.remove(at: from)
    colors.insert(color, at: to)
  }
}
