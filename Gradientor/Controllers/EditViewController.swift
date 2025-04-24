//
//  EditViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import GameplayKit
import UIKit

class EditViewController: UITableViewController {
  let reuseIdentifier = "reuseIdentifier"

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

    segmentedControl.selectedSegmentIndex = AppState.shared.direction.rawValue
    segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)

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

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    tableView.separatorStyle = .none

    updateUI()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateUI),
      name: .colorsDidChange,
      object: AppState.shared
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    tableView.reloadData()
  }

  // MARK - Utilities

  @objc private func updateUI() {
    title = String(
      format: NSLocalizedString("%d colors", comment: ""), AppState.shared.colors.count)
  }

  // MARK - Actions

  @objc private func addDidTap() {
    let addViewController = AddViewController()
    navigationController?.pushViewController(addViewController, animated: true)
  }

  @objc private func segmentDidChange(_ sender: UISegmentedControl) {
    let direction = Gradient.Direction(rawValue: sender.selectedSegmentIndex) ?? .vertical
    AppState.shared.direction = direction
  }
}

extension EditViewController /*: UITableViewDataSource, UITableViewDelegate */ {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return AppState.shared.colors.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    let color = AppState.shared.colors[indexPath.row]
    cell.textLabel?.text = color.hexValue()
    cell.textLabel?.textColor = color.contrastColor()

    let backgroundView = UIView()
    backgroundView.backgroundColor = color
    cell.backgroundView = backgroundView

    return cell
  }

  override func tableView(
    _ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath
  ) {
    AppState.shared.moveColor(from: sourceIndexPath.row, to: destinationIndexPath.row)
  }

  override func tableView(
    _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    if editingStyle == .delete {
      AppState.shared.colors.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}
