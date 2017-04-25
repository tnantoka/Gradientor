//
//  EditViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit
import GameplayKit

import RxSwift
import RxCocoa
import ChameleonFramework
import IoniconsKit

class EditViewController: UITableViewController {

    private let bag = DisposeBag()
    private let store = RxStore<AppState>(store: mainStore)

    lazy private var addItem: UIBarButtonItem = {
        let addItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        addItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        addItem.title = String.ionicon(with: .plus)

        addItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.addDidTap()
            })
            .addDisposableTo(self.bag)
        return addItem
    }()
    lazy private var directionControl: UISegmentedControl = {
        let size = CGSize(width: 24.0, height: 24.0)
        let segmentedControl = UISegmentedControl(items: [
            UIImage.ionicon(with: .minus, textColor: .black, size: size),
            UIImage.ionicon(with: .minus, textColor: .black, size: size).rotated(degree: 90.0),
            UIImage.ionicon(with: .androidRadioButtonOff, textColor: .black, size: size),
            UIImage.ionicon(with: .minus, textColor: .black, size: size).rotated(degree: 45.0),
            UIImage.ionicon(with: .minus, textColor: .black, size: size).rotated(degree: -45.0)
        ])
        segmentedControl.selectedSegmentIndex = mainStore.state.direction.rawValue
        segmentedControl.rx.selectedSegmentIndex
            .asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .map { Gradient.Direction(rawValue: $0) ?? .vertical }
            .subscribe(onNext: { [weak self] direction in
                mainStore.dispatch(AppAction.setDirection(direction))
            })
            .addDisposableTo(self.bag)
        return segmentedControl
    }()
    lazy private var directionItem: UIBarButtonItem = {
        let directionItem = UIBarButtonItem(customView: self.directionControl)
        return directionItem
    }()
    private let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

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
                cell.backgroundColor = model
                cell.textLabel?.text = model.hexValue()
                cell.textLabel?.textColor = ContrastColorOf(model, returnFlat: false)
                let bgView = UIView()
                bgView.backgroundColor = model
                cell.backgroundView = bgView
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK - Utilities

    private func updateUI(colors: [UIColor]) {
        title = NSLocalizedString("\(colors.count) colors", comment: "")
    }

    // MARK - Actions

    private func addDidTap() {
        let colorsViewController = ColorsViewController()

        colorsViewController.selectedColors
            .distinctUntilChanged()
            .subscribe(onNext: { newColor in
                mainStore.dispatch(AppAction.addColor(newColor))
            })
            .addDisposableTo(colorsViewController.bag)

        navigationController?.pushViewController(colorsViewController, animated: true)
    }
}

extension UIImage {
    fileprivate func rotated(degree: Float) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)

        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: 1.0, y: -1.0)

        let radian = CGFloat(GLKMathDegreesToRadians(degree))
        context.rotate(by: radian)

        guard let cgImage = cgImage else { return UIImage() }
        context.draw(cgImage, in: CGRect(origin: CGPoint(x: -center.x, y: -center.y), size: size))

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        return image
    }
}
