//
//  AddViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/26.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
  private let reuseIdentifier = "reuseIdentifier"

  var didDone: () -> Void = {}
  var didAdd: () -> Void = {}

  lazy internal var doneItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(doneDidTap)
    )
  }()
  lazy internal var randomItem: UIBarButtonItem = {
    barButtonItem(systemName: "shuffle", target: self, action: #selector(throttledRandomDidTap))
  }()
  lazy internal var rgbItem: UIBarButtonItem = {
    barButtonItem(systemName: "number", target: self, action: #selector(rgbDidTap))
  }()
  private let flexibleItem = UIBarButtonItem(
    barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

  private var lastRandomTapTime = Date.distantPast
  private var selectedGroup = 0 {
    didSet {
      tableView.reloadData()
    }
  }

  lazy private var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()

    let length = view.bounds.width / 10.0
    layout.itemSize = CGSize(width: length, height: length)
    layout.minimumLineSpacing = 0.0
    layout.minimumInteritemSpacing = 0.0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.backgroundColor = .clear

    collectionView.dataSource = self
    collectionView.delegate = self

    return collectionView
  }()

  lazy private var tableView: UITableView = {
    let tableView = UITableView()

    tableView.separatorStyle = .none
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = MaterialDesign.backgroundColor

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = MaterialDesign.names[0]
    view.backgroundColor = MaterialDesign.backgroundColor

    navigationItem.leftBarButtonItem = doneItem
    toolbarItems = [flexibleItem, randomItem, flexibleItem, rgbItem, flexibleItem]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: view.bounds.width / 5.0),
    ])

    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  // MARK - Utilities

  fileprivate func showSuccess(subtitle: String?) {
    let config = UIImage.SymbolConfiguration(pointSize: 64.0, weight: .regular)
    let image = UIImage(systemName: "checkmark", withConfiguration: config)?.withTintColor(
      UIColor(white: 0.0, alpha: 0.87), renderingMode: .alwaysOriginal)

    let hudSize = CGSize(width: 180.0, height: 180.0)
    let hudOrigin = CGPoint(
      x: view.bounds.width * 0.5 - hudSize.width * 0.5,
      y: view.bounds.height * 0.5 - hudSize.height * 0.5
    )
    let hudFrame = CGRect(origin: hudOrigin, size: hudSize)
    let hudView = UIView(frame: hudFrame)
    hudView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    hudView.layer.cornerRadius = 8.0

    let imageView = UIImageView(image: image)
    imageView.frame.origin = CGPoint(
      x: hudSize.width * 0.5 - imageView.bounds.width * 0.5,
      y: hudSize.height * 0.5 - imageView.bounds.height * 0.6
    )
    hudView.addSubview(imageView)

    let labelHeight = 44.0
    let label = UILabel(
      frame: CGRect(
        x: 0.0,
        y: hudSize.height - labelHeight * 1.5,
        width: hudSize.width,
        height: labelHeight
      )
    )
    label.text = subtitle
    label.textAlignment = .center
    label.textColor = UIColor(white: 0.0, alpha: 0.87)
    hudView.addSubview(label)

    let backdropView = UIView(frame: view.bounds)
    backdropView.backgroundColor = .clear
    backdropView.addSubview(hudView)
    view.addSubview(backdropView)

    UIView.animate(
      withDuration: 0.3, delay: 0.3, options: [],
      animations: {
        backdropView.alpha = 0
      },
      completion: { _ in
        backdropView.removeFromSuperview()
      })
  }

  private func addColor(_ color: UIColor) {
    AppState.shared.colors.append(color)
    showSuccess(subtitle: color.hexValue())
    didAdd()
  }

  // MARK - Actions

  @objc private func doneDidTap() {
    didDone()
  }

  @objc private func throttledRandomDidTap() {
    let now = Date()

    if now.timeIntervalSince(lastRandomTapTime) >= 0.5 {
      lastRandomTapTime = now
      randomDidTap()
    }
  }

  @objc private func randomDidTap() {
    addColor(AppState.randomColor)
  }

  @objc private func rgbDidTap() {
    let alertController = UIAlertController(
      title: NSLocalizedString("Add Color", comment: ""),
      message: NSLocalizedString("Enter a color code.", comment: ""),
      preferredStyle: .alert
    )

    alertController.addTextField { textField in
      textField.placeholder = "RRGGBB"
    }

    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Cancel", comment: ""),
        style: .cancel,
        handler: nil
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Add", comment: ""),
        style: .default
      ) { [weak self] _ in
        guard let rgb = alertController.textFields?.first?.text else { return }
        let code = rgb.trimmingCharacters(in: .whitespacesAndNewlines)
        self?.addColor(UIColor(hexString: code))
      }
    )

    present(alertController, animated: true, completion: nil)
  }
}

extension AddViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
    -> Int
  {
    return MaterialDesign.mainColors.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier, for: indexPath)

    let color = MaterialDesign.mainColors[indexPath.row]
    cell.backgroundColor = color

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) else { return }

    let color = MaterialDesign.mainColors[indexPath.row]
    selectedGroup = indexPath.row
    title = MaterialDesign.names[indexPath.row]

    let overlayView = UIView(frame: cell.contentView.bounds)
    overlayView.backgroundColor = color.contrastColor()
    cell.contentView.addSubview(overlayView)

    overlayView.alpha = 0.3
    UIView.animate(
      withDuration: 0.3,
      animations: {
        overlayView.alpha = 0.0
      }
    ) { _ in
      overlayView.removeFromSuperview()
    }

  }
}

extension AddViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MaterialDesign.colorGroups[selectedGroup].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    let color = MaterialDesign.colorGroups[selectedGroup][indexPath.row]
    cell.textLabel?.text = color.hexValue()
    cell.textLabel?.textColor = color.contrastColor()
    cell.selectionStyle = .none

    cell.backgroundColor = color

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }

    let color = MaterialDesign.colorGroups[selectedGroup][indexPath.row]
    addColor(color)

    let overlayView = UIView(frame: cell.contentView.bounds)
    overlayView.backgroundColor = color.contrastColor()
    cell.contentView.addSubview(overlayView)

    overlayView.alpha = 0.3
    UIView.animate(
      withDuration: 0.3,
      animations: {
        overlayView.alpha = 0.0
      }
    ) { _ in
      overlayView.removeFromSuperview()
    }
  }
}
