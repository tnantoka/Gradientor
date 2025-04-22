//
//  EditViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import GameplayKit
import RxCocoa
import RxSwift
import UIKit

class EditViewController: UITableViewController {

  private let bag = DisposeBag()
  private let store = RxStore<AppState>(store: mainStore)

  lazy internal var addItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addDidTap)
    )
  }()
  lazy private var directionControl: UISegmentedControl = {
    let config = UIImage.SymbolConfiguration(pointSize: 18.0, weight: .regular)

    let segmentedControl = UISegmentedControl(
      items: [
        UIImage(systemName: "minus", withConfiguration: config),
        UIImage(systemName: "minus", withConfiguration: config)?.rotated(degree: 90.0),
        UIImage(systemName: "circle", withConfiguration: config),
        UIImage(systemName: "line.diagonal", withConfiguration: config),
        UIImage(systemName: "line.diagonal", withConfiguration: config)?.rotated(degree: 90.0),
      ].compactMap { $0 })
    segmentedControl.selectedSegmentIndex = mainStore.state.direction.rawValue
    segmentedControl.rx.selectedSegmentIndex
      .asObservable()
      .throttle(0.5, scheduler: MainScheduler.instance)
      .map { Gradient.Direction(rawValue: $0) ?? .vertical }
      .subscribe(onNext: { direction in
        mainStore.dispatch(AppAction.setDirection(direction))
      })
      .addDisposableTo(self.bag)
    return segmentedControl
  }()
  lazy internal var directionItem: UIBarButtonItem = {
    UIBarButtonItem(customView: self.directionControl)
  }()
  private let flexibleItem = UIBarButtonItem(
    barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    isEditing = true
    navigationItem.rightBarButtonItem = addItem
    toolbarItems = [flexibleItem, directionItem, flexibleItem]

    tableView.delegate = nil
    tableView.dataSource = nil
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.separatorColor = .clear

    let colors = store.state.asDriver()
      .map { $0.colors }
    colors.drive(tableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
      cell.textLabel?.text = model.hexValue()
      cell.textLabel?.textColor = model.contrastColor()

      let backgroundView = UIView()
      backgroundView.backgroundColor = model
      cell.backgroundView = backgroundView
    }
    .addDisposableTo(bag)
    colors.drive(onNext: { [weak self] colors in
      self?.updateUI(colors: colors)
    })
    .addDisposableTo(bag)

    tableView.rx.itemMoved.subscribe(onNext: { fromIndex, toIndex in
      mainStore.dispatch(AppAction.moveColor(from: fromIndex.row, to: toIndex.row))
    })
    .addDisposableTo(bag)
    tableView.rx.itemDeleted.subscribe(onNext: { indexPath in
      mainStore.dispatch(AppAction.deleteColor(indexPath.row))
    })
    .addDisposableTo(bag)
  }

  // MARK - Utilities

  private func updateUI(colors: [UIColor]) {
    title = String(format: NSLocalizedString("%d colors", comment: ""), colors.count)
  }

  // MARK - Actions

  @objc private func addDidTap() {
    let addViewController = AddViewController()
    navigationController?.pushViewController(addViewController, animated: true)
  }
}
