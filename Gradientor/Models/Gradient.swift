//
//  Gradient.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import ChameleonFramework

struct Gradient {

    enum Direction: Int {
        case horizontal
        case vertical
        case radial
        case diagonalLR
        case diagonalRL
    }

    var layer = LinerLayer()

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
                    layer = LinerLayer()
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

    static var flatColors: [UIColor] = [
        .flatBlack, .flatBlackDark,
        .flatBlue, .flatBlueDark,
        .flatBrown, .flatBrownDark,
        .flatCoffee, .flatCoffeeDark,
        .flatForestGreen, .flatForestGreenDark,
        .flatGray, .flatGrayDark,
        .flatGreen, .flatGreenDark,
        .flatLime, .flatLimeDark,
        .flatMagenta, .flatMagentaDark,
        .flatMaroon, .flatMaroonDark,
        .flatMint, .flatMintDark,
        .flatNavyBlue, .flatNavyBlueDark,
        .flatOrange, .flatOrangeDark,
        .flatPink, .flatPinkDark,
        .flatPlum, .flatPlumDark,
        .flatPowderBlue, .flatPowderBlueDark,
        .flatPurple, .flatPurpleDark,
        .flatRed, .flatRedDark,
        .flatSand, .flatSandDark,
        .flatSkyBlue, .flatSkyBlueDark,
        .flatTeal, .flatTealDark,
        .flatWatermelon, .flatWatermelonDark,
        .flatWhite, .flatWhiteDark,
        .flatYellow, .flatYellowDark
    ]
}

class LinerLayer: CAGradientLayer {
}

class RadialLayer: CAGradientLayer {
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
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: locations
        ) else { return }

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
