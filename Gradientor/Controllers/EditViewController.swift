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

        colors.drive(tableView.rx.items(cellIdentifier: "Cell")) { index, model, cell in
                cell.backgroundColor = model
            }
            .addDisposableTo(bag)

        colors.drive(onNext: { [weak self] colors in
                self?.updateUI(colors: colors)
            })
            .addDisposableTo(bag)

        tableView.rx.itemMoved.subscribe(onNext: { from, to in
                mainStore.dispatch(AppAction.moveColor(from: from.row, to: to.row))
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK - Utilities

    private func updateUI(colors: [UIColor]) {
        title = NSLocalizedString("\(colors.count) colors", comment: "")
    }

    // MARK - Actions

    private func addDidTap() {
        let colorsViewController = ColorsViewController()

        let newColors = colorsViewController.selectedColors
            .share()

        newColors
            .distinctUntilChanged()
            .subscribe(onNext: { newColor in
                mainStore.dispatch(AppAction.addColor(newColor))
            })
            .addDisposableTo(colorsViewController.bag)
//        newColors
//            .ignoreElements()
//            .subscribe(onCompleted: { [weak self] in
//                self?.tableView.reloadData()
//            })
//            .addDisposableTo(colorsViewController.bag)

        navigationController?.pushViewController(colorsViewController, animated: true)
    }
}
