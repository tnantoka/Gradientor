//
//  HomeViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/17.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import AdFooter
import GameplayKit
import UIKit

class HomeViewController: UIViewController {
  private let reuseIdentifier = "reuseIdentifier"

  internal var gradient = Gradient()

  lazy internal var infoItem: UIBarButtonItem = {
    self.barButtonItem(systemName: "info", target: self, action: #selector(infoDidTap))
  }()
  lazy internal var addItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addDidTap)
    )
  }()

  lazy internal var deleteItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .trash,
      target: self,
      action: #selector(deleteDidTap)
    )
  }()
  lazy internal var refreshItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .refresh,
      target: self,
      action: #selector(refreshDidTap)
    )
  }()
  lazy internal var exportItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .action,
      target: self,
      action: #selector(exportDidTap)
    )
  }()
  private let flexibleItem = UIBarButtonItem(
    barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
  lazy private var directionControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(
      items: [
        UIImage(systemName: "minus"),
        UIImage(systemName: "minus")?.rotated(degree: 90.0),
        UIImage(systemName: "circle"),
        UIImage(systemName: "line.diagonal"),
        UIImage(systemName: "line.diagonal")?.rotated(degree: 90.0),
      ].compactMap { $0 })

    segmentedControl.selectedSegmentIndex = AppState.shared.direction.rawValue
    segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)

    return segmentedControl
  }()
  lazy internal var directionItem: UIBarButtonItem = {
    UIBarButtonItem(customView: self.directionControl)
  }()
  lazy private var gradientView: UIView = {
    let gradientView = UIView()

    gradientView.backgroundColor = MaterialDesign.backgroundColor

    return gradientView
  }()

  lazy private var tableView: UITableView = {
    let tableView = UITableView()

    tableView.separatorStyle = .none
    tableView.dataSource = self
    tableView.delegate = self
    tableView.isEditing = true
    tableView.allowsMultipleSelectionDuringEditing = true
    tableView.backgroundColor = MaterialDesign.backgroundColor

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    return tableView
  }()

  lazy private var borderView: UIView = {
    let borderView = UIView()

    borderView.backgroundColor = MaterialDesign.backgroundColor

    return borderView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = MaterialDesign.backgroundColor

    navigationItem.leftBarButtonItem = infoItem
    navigationItem.rightBarButtonItems = [addItem, deleteItem]
    toolbarItems = [
      refreshItem, flexibleItem, directionItem, flexibleItem, exportItem,
    ]

    view.addSubview(gradientView)
    gradientView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      gradientView.topAnchor.constraint(equalTo: view.topAnchor),
      gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      gradientView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
      gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    view.addSubview(borderView)
    borderView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      borderView.topAnchor.constraint(equalTo: view.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      borderView.widthAnchor.constraint(equalToConstant: 1.0),
      borderView.leadingAnchor.constraint(equalTo: gradientView.trailingAnchor),
    ])

    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: borderView.trailingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if AppState.shared.colors.isEmpty {
      refresh()
    }
    #if DEBUG
      //            setIconColors(); let fixme = ""
    #endif
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    updateUI()
  }

  // MARK - Utilities

  internal func setIconColors() {
    AppState.shared.colors = [
      MaterialDesign.flatBlueColor,
      MaterialDesign.flatPowderBlueDarkColor,
      MaterialDesign.flatPowderBlueColor,
    ]
  }

  private func updateGradient() {
    let colors = AppState.shared.colors

    gradientView.layer.sublayers?.forEach { sublayer in
      if sublayer.isKind(of: GradientLayer.self) {
        sublayer.removeFromSuperlayer()
      }
    }

    gradient.direction = AppState.shared.direction
    gradient.colors = colors
    gradient.frame = gradientView.bounds

    gradientView.layer.addSublayer(gradient.layer)
  }

  @objc private func updateUI() {
    tableView.reloadData()

    updateGradient()
    updateButtonState()

    title = String(
      format: NSLocalizedString("%d colors", comment: ""), AppState.shared.colors.count)
  }

  private func updateButtonState() {
    deleteItem.isEnabled = tableView.indexPathsForSelectedRows?.count ?? 0 > 0
    exportItem.isEnabled = AppState.shared.colors.count > 0
  }

  private func refresh() {
    AppState.shared.colors = [
      AppState.randomColor,
      AppState.randomColor,
    ]
  }

  private func confirm(title: String, actionTitle: String, didConfirm: @escaping () -> Void) {
    let alertController = UIAlertController(
      title: title,
      message: NSLocalizedString("Are you sure?", comment: ""),
      preferredStyle: .alert
    )

    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Cancel", comment: ""),
        style: .cancel,
        handler: nil
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: actionTitle,
        style: .destructive
      ) { _ in
        didConfirm()
      }
    )

    present(alertController, animated: true, completion: nil)
  }

  private func showInterstitial() {
    #if DEBUG
      let threshold = 1
    #else
      let threshold = GKRandomDistribution(lowestValue: 3, highestValue: 5).nextInt()
    #endif
    if AppState.shared.exportCount % threshold == 0 {
      AdFooter.shared.interstitial.present(for: self)
    }
  }

  // MARK - Actions

  @objc private func addDidTap() {
    let addViewController = AddViewController()

    addViewController.didDone = { [weak self] in
      self?.dismiss(animated: true)
    }
    addViewController.didAdd = { [weak self] in
      self?.updateUI()
    }

    let addNavigationController = UINavigationController(
      rootViewController: addViewController)
    addNavigationController.navigationBar.isTranslucent = false

    present(addNavigationController, animated: true, completion: nil)
  }

  @objc private func infoDidTap() {
    let aboutViewController = AboutViewController(style: .grouped)

    let aboutNavigationController = UINavigationController(rootViewController: aboutViewController)
    aboutNavigationController.navigationBar.isTranslucent = false

    present(aboutNavigationController, animated: true, completion: nil)
  }

  @objc private func deleteDidTap() {
    guard let indexPaths = tableView.indexPathsForSelectedRows else { return }

    indexPaths.map { $0.row }.sorted(by: >).forEach { AppState.shared.colors.remove(at: $0) }
    updateUI()
  }

  @objc private func refreshDidTap() {
    confirm(
      title: NSLocalizedString("Recreate Colors", comment: ""),
      actionTitle: NSLocalizedString("OK", comment: "")
    ) { [weak self] in
      self?.refresh()
      self?.updateUI()
    }
  }

  @objc private func exportDidTap() {
    let exportViewController = ExportViewController()

    exportViewController.didClose = { [weak self] in
      self?.dismiss(animated: true) {
        self?.showInterstitial()
      }
    }

    let exportNavigationController = UINavigationController(
      rootViewController: exportViewController)
    exportNavigationController.navigationBar.isTranslucent = false

    present(exportNavigationController, animated: true, completion: nil)
  }

  @objc private func segmentDidChange(_ sender: UISegmentedControl) {
    let direction = Gradient.Direction(rawValue: sender.selectedSegmentIndex) ?? .vertical
    AppState.shared.direction = direction
    updateGradient()
  }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let cellHeight = 44.0
    let tableHeight = tableView.bounds.height
    let minimumCellCount = Int(ceil(tableHeight / cellHeight))

    return max(minimumCellCount, AppState.shared.colors.count)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    if indexPath.row > AppState.shared.colors.count - 1 {
      cell.textLabel?.text = ""
      cell.backgroundColor = indexPath.row % 2 == 0 ? .clear : MaterialDesign.colorGroups[18][0]
      cell.selectionStyle = .none
      cell.selectedBackgroundView = nil
      return cell
    }

    let color = AppState.shared.colors[indexPath.row]
    cell.textLabel?.text = color.hexValue()
    cell.textLabel?.textColor = color.contrastColor()

    cell.backgroundColor = color
    cell.selectionStyle = .default

    let selectedBackgroundView = UIView()
    selectedBackgroundView.backgroundColor = color
    cell.selectedBackgroundView = selectedBackgroundView

    return cell
  }

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row < AppState.shared.colors.count
  }

  func tableView(
    _ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
    toProposedIndexPath proposedDestinationIndexPath: IndexPath
  ) -> IndexPath {
    if proposedDestinationIndexPath.row > AppState.shared.colors.count - 1 {
      return IndexPath(row: AppState.shared.colors.count - 1, section: sourceIndexPath.section)
    }

    return proposedDestinationIndexPath
  }

  func tableView(
    _ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath
  ) {
    AppState.shared.moveColor(from: sourceIndexPath.row, to: destinationIndexPath.row)
    updateGradient()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row < AppState.shared.colors.count {
      updateButtonState()
    } else {
      tableView.deselectRow(at: indexPath, animated: false)
      addDidTap()
    }
  }

  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    updateButtonState()
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row < AppState.shared.colors.count
  }
}
