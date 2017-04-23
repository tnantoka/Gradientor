//
//  AppReducer.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Foundation

import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    guard let appAction = action as? AppAction else { return state }

    switch appAction {
    case .addColor(let color):
        state.colors.append(color)
    case .clearColors:
        state.colors = []
    case let .moveColor(from, to):
        let color = state.colors.remove(at: from)
        state.colors.insert(color, at: to)
    case .deleteColor(let index):
        state.colors.remove(at: index)
    }

    return state
}