//
//  RxStore.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift

class RxStore<AppStateType: StateType>: StoreSubscriber {
  let state: Variable<AppStateType>
  private let store: Store<AppStateType>

  init(store: Store<AppStateType>) {
    self.store = store
    state = Variable(store.state)

    store.subscribe(self)
  }

  deinit {
    store.unsubscribe(self)
  }

  func newState(state: AppStateType) {
    self.state.value = state
  }
}
