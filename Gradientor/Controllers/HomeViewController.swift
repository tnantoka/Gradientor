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

  internal var gradient = Gradient()

  lazy internal var infoItem: UIBarButtonItem = {
    self.barButtonItem(systemName: "info", target: self, action: #selector(infoDidTap))
  }()
  lazy internal var editItem: UIBarButtonItem = {
    self.barButtonItem(systemName: "pencil", target: self, action: #selector(editDidTap))
  }()

  lazy internal var clearItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .trash,
      target: self,
      action: #selector(clearDidTap)
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

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Gradientor", comment: "")
    view.backgroundColor = MaterialDesign.backgroundColor

    navigationItem.leftBarButtonItem = infoItem
    navigationItem.rightBarButtonItem = editItem
    toolbarItems = [
      flexibleItem, clearItem, flexibleItem, refreshItem, flexibleItem, exportItem, flexibleItem,
    ]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if AppState.shared.colors.isEmpty {
      refresh()
    }
    #if DEBUG
      //            setIconColors(); let fixme = ""
    #endif

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

  private func updateGradient(colors: [UIColor]) {
    view.layer.sublayers?.forEach { sublayer in
      if sublayer.isKind(of: GradientLayer.self) {
        sublayer.removeFromSuperlayer()
      }
    }

    gradient.direction = AppState.shared.direction
    gradient.colors = colors
    gradient.frame = view.bounds

    view.layer.addSublayer(gradient.layer)
  }

  private func updateUI() {
    let colors = AppState.shared.colors
    updateGradient(colors: colors)
    clearItem.isEnabled = colors.count > 1
    exportItem.isEnabled = colors.count > 1
  }

  private func clear() {
    AppState.shared.colors = []
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

  @objc private func editDidTap() {
    let editViewController = EditViewController()
    navigationController?.pushViewController(editViewController, animated: true)
  }

  @objc private func infoDidTap() {
    let aboutViewController = AboutViewController(style: .grouped)

    let aboutNavigationController = UINavigationController(rootViewController: aboutViewController)
    aboutNavigationController.navigationBar.isTranslucent = false

    present(aboutNavigationController, animated: true, completion: nil)
  }

  @objc private func clearDidTap() {
    confirm(
      title: NSLocalizedString("Delete All Colors", comment: ""),
      actionTitle: NSLocalizedString("Delete", comment: "")
    ) { [weak self] in
      self?.clear()
      self?.updateUI()
    }
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
}
