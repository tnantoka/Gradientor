//
//  AddViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/26.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import ChameleonFramework
import PKHUD
import IoniconsKit
import SnapKit

class AddViewController: UIViewController {

    let bag = DisposeBag()
    let groupColors = Variable(MaterialDesign.colorGroups[0])

    lazy private var randomItem: UIBarButtonItem = {
        let randomItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        randomItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        randomItem.title = String.ionicon(with: .shuffle)

        randomItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let color = AppState.randomColor
                mainStore.dispatch(AppAction.addColor(color))
                self?.showSuccess(subtitle: color.hexValue())
            })
            .addDisposableTo(self.bag)
        return randomItem
    }()
    lazy private var imageItem: UIBarButtonItem = {
        let imageItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        imageItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        imageItem.title = String.ionicon(with: .image)

        imageItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.imageDidTap()
            })
            .addDisposableTo(self.bag)
        return imageItem
    }()
    lazy private var rgbItem: UIBarButtonItem = {
        let rgbItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        rgbItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
        ], for: .normal)
        rgbItem.title = String.ionicon(with: .pound)

        rgbItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.rgbDidTap()
            })
            .addDisposableTo(self.bag)
        return rgbItem
    }()
    private let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let length = UIScreen.main.bounds.width / 10.0
        layout.itemSize = CGSize(width: length, height: length)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
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
                cell.backgroundColor = model
                cell.textLabel?.text = model.hexValue()
                cell.textLabel?.textColor = ContrastColorOf(model, returnFlat: false)
                cell.selectionStyle = .none
            }
            .addDisposableTo(self.bag)

        tableView.rx.modelSelected(UIColor.self)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] color in
                mainStore.dispatch(AppAction.addColor(color))
                self?.showSuccess(subtitle: color.hexValue())
            })
            .addDisposableTo(self.bag)

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = MaterialDesign.backgroundColor

        toolbarItems = [flexibleItem, randomItem, flexibleItem, imageItem, flexibleItem, rgbItem, flexibleItem]

        PKHUD.sharedHUD.dimsBackground = false

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(UIScreen.main.bounds.width / 5.0)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }

    // MARK - Actions

    private func rgbDidTap() {
        let alertViewController = UIAlertController(
            title: NSLocalizedString("Add Color", comment: ""),
            message: NSLocalizedString("Enter a color code.", comment: ""),
            preferredStyle: .alert
        )

        alertViewController.addTextField { textField in
            textField.placeholder = "RRGGBB"
        }

        alertViewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        alertViewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Add", comment: ""),
                style: .default
            ) { [weak self]_ in
                guard let rgb = alertViewController.textFields?.first?.text else { return }
                let code = rgb.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let color = UIColor(hexString: code) else { return }
                mainStore.dispatch(AppAction.addColor(color))
                self?.showSuccess(subtitle: color.hexValue())
            }
        )

        present(alertViewController, animated: true, completion: nil)
    }

    private func imageDidTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    // MARK - Utilities

    fileprivate func showSuccess(subtitle: String?) {
        let size = CGSize(width: 88.0, height: 88.0)
        let image = UIImage.ionicon(with: .iosCheckmarkEmpty, textColor: UIColor(white: 0.0, alpha: 0.87), size: size)
        HUD.flash(.labeledImage(image: image, title: nil, subtitle: subtitle), delay: 0.5)
    }
}

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        HUD.show(.systemActivity)
        DispatchQueue.global().async { [weak self] in
            let colors = ColorsFromImage(image, withFlatScheme: false)
            DispatchQueue.main.async {
                mainStore.dispatch(AppAction.addColors(colors))
                self?.showSuccess(subtitle: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
