//
//  AddViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/26.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class AddViewController: UIViewController {

  let bag = DisposeBag()
  let groupColors = Variable(MaterialDesign.colorGroups[0])

  lazy internal var randomItem: UIBarButtonItem = {
    self.barButtomItem(systemName: "shuffle", bag: self.bag) { [weak self] in
      self?.randomDidTap()
    }
  }()
  lazy internal var rgbItem: UIBarButtonItem = {
    self.barButtomItem(systemName: "number", bag: self.bag) { [weak self] in
      self?.rgbDidTap()
    }
  }()
  private let flexibleItem = UIBarButtonItem(
    barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

  lazy private var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()

    let length = UIScreen.main.bounds.width / 10.0
    layout.itemSize = CGSize(width: length, height: length)
    layout.minimumLineSpacing = 0.0
    layout.minimumInteritemSpacing = 0.0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = .clear

    let items = Variable(MaterialDesign.mainColors)
    items.asDriver()
      .drive(collectionView.rx.items(cellIdentifier: "Cell")) { _, element, cell in
        cell.backgroundColor = element
      }
      .addDisposableTo(self.bag)

    collectionView.rx.itemSelected
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] indexPath in
        self?.groupColors.value = MaterialDesign.colorGroups[indexPath.row]
        self?.title = MaterialDesign.names[indexPath.row]

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let backgroundColor = cell.backgroundColor else { return }

        let overlayView = UIView(frame: cell.contentView.bounds)
        overlayView.backgroundColor = backgroundColor.contrastColor()
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
      })
      .addDisposableTo(self.bag)

    return collectionView
  }()

  lazy private var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.separatorColor = .clear

    self.groupColors.asDriver()
      .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
        cell.textLabel?.text = model.hexValue()
        cell.textLabel?.textColor = model.contrastColor()
        cell.selectionStyle = .none

        let backgroundView = UIView()
        backgroundView.backgroundColor = model
        cell.backgroundView = backgroundView
      }
      .addDisposableTo(self.bag)

    tableView.rx.modelSelected(UIColor.self)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] color in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          mainStore.dispatch(AppAction.addColor(color))
          self?.showSuccess(subtitle: color.hexValue())
        }
      })
      .addDisposableTo(self.bag)
    tableView.rx.itemSelected
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let backgroundColor = cell.backgroundColor else { return }

        let overlayView = UIView(frame: cell.contentView.bounds)
        overlayView.backgroundColor = backgroundColor.contrastColor()
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
      })
      .addDisposableTo(self.bag)

    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = MaterialDesign.names[0]
    view.backgroundColor = MaterialDesign.backgroundColor

    toolbarItems = [flexibleItem, randomItem, flexibleItem, rgbItem, flexibleItem]

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 5.0),
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
      withDuration: 0.3, delay: 1.0, options: [],
      animations: {
        backdropView.alpha = 0
      },
      completion: { _ in
        backdropView.removeFromSuperview()
      })
  }

  // MARK - Actions

  private func randomDidTap() {
    let color = AppState.randomColor
    mainStore.dispatch(AppAction.addColor(color))
    showSuccess(subtitle: color.hexValue())
  }

  private func rgbDidTap() {
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
        let color = UIColor(hexString: code)
        mainStore.dispatch(AppAction.addColor(color))
        self?.showSuccess(subtitle: color.hexValue())
      }
    )

    present(alertController, animated: true, completion: nil)
  }
}
