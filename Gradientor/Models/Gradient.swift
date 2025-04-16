//
//  Gradient.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

struct Gradient {

  enum Direction: Int {
    case horizontal
    case vertical
    case radial
    case diagonalLR
    case diagonalRL
  }

  var layer: GradientLayer = LinerLayer()

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
  var direction = Direction.horizontal {
    didSet {
      switch direction {
      case .horizontal:
        if layer.isKind(of: RadialLayer.self) {
          layer = LinerLayer()
        }
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
      case .vertical:
        if layer.isKind(of: RadialLayer.self) {
          layer = LinerLayer()
        }
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
      case .radial:
        if !layer.isKind(of: RadialLayer.self) {
          layer = RadialLayer()
        }
      case .diagonalLR:
        if layer.isKind(of: RadialLayer.self) {
          layer = LinerLayer()
        }
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
      case .diagonalRL:
        if layer.isKind(of: RadialLayer.self) {
          layer = LinerLayer()
        }
        layer.startPoint = CGPoint(x: 1.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
      }
    }
  }

  var image: UIImage {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0)
    defer {
      UIGraphicsEndImageContext()
    }
    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    layer.render(in: context)
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
    return image
  }

  var text: String {
    return colors.map { $0.hexValue() }.joined(separator: ", ")
  }
}

class GradientLayer: CAGradientLayer {
}

class LinerLayer: GradientLayer {
}

class RadialLayer: GradientLayer {
  override var colors: [Any]? {
    didSet {
      setNeedsDisplay()
    }
  }

  override var frame: CGRect {
    didSet {
      setNeedsDisplay()
    }
  }

  override func draw(in ctx: CGContext) {
    guard let colors = colors, colors.count > 1 else { return }

    let locations = stride(from: 0.0, to: 1.0, by: 1.0 / Double(colors.count)).map { CGFloat($0) }
    guard
      let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: colors as CFArray,
        locations: locations
      )
    else { return }

    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    ctx.drawRadialGradient(
      gradient,
      startCenter: center,
      startRadius: 0.0,
      endCenter: center,
      endRadius: min(bounds.width, bounds.height),
      options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )
  }
}
