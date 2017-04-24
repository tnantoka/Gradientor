//
//  EditViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/22.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class EditViewController: UITableViewController {

    private let bag = DisposeBag()
    private let store = RxStore<AppState>(store: mainStore)

    lazy private var addItem: UIBarButtonItem = {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.addDidTap()
            })
            .addDisposableTo(self.bag)
        return addItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        isEditing = true
        navigationItem.rightBarButtonItem = addItem

        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        let colors = store.state.asDriver()
            .map { $0.colors }

        colors.drive(tableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
                cell.backgroundColor = model
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
