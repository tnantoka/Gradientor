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

private let reuseIdentifier = "Cell"

class AddViewController: UICollectionViewController {

    let bag = DisposeBag()

    fileprivate let selectedColorsSubject = PublishSubject<UIColor>()
    var selectedColors: Observable<UIColor> {
        return selectedColorsSubject.asObservable()
    }

    lazy private var randomItem: UIBarButtonItem = {
        let randomItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        randomItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.ionicon(of: 22.0)
            ], for: .normal)
        randomItem.title = String.ionicon(with: .shuffle)

        randomItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                mainStore.dispatch(AppAction.addRandomColor)
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
    
    init() {
        let layout = UICollectionViewFlowLayout()

        let length = UIScreen.main.bounds.width / 6.0
        layout.itemSize = CGSize(width: length, height: length)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0

        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        toolbarItems = [flexibleItem, randomItem, flexibleItem, imageItem, flexibleItem, rgbItem, flexibleItem]

        guard let collectionView = collectionView else { return }
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true

        let items = Variable(Gradient.flatColors)
        items.asDriver()
            .drive(collectionView.rx.items(cellIdentifier: reuseIdentifier)) { row, element, cell in
                cell.backgroundColor = element
            }
            .addDisposableTo(bag)

        collectionView.rx.modelSelected(UIColor.self)
            .distinctUntilChanged()
            .subscribe(onNext: { color in
                mainStore.dispatch(AppAction.addColor(color))
            })
            .addDisposableTo(bag)

        collectionView.rx.itemSelected
            .distinctUntilChanged()
            .subscribe(onNext: { indexPath in
                guard let cell = collectionView.cellForItem(at: indexPath) else { return }

                let color = Gradient.flatColors[indexPath.row]
                let bgView = UIView()
                bgView.backgroundColor = ContrastColorOf(color, returnFlat: false)

                cell.selectedBackgroundView = bgView
                cell.selectedBackgroundView?.alpha = 0.3
                UIView.animate(withDuration: 0.5, animations: {
                    cell.selectedBackgroundView?.alpha = 0.0
                }) { _ in
                    cell.selectedBackgroundView = nil
                }
            })
            .addDisposableTo(bag)
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
            ) { _ in
                guard let rgb = alertViewController.textFields?.first?.text else { return }
                let code = rgb.replacingOccurrences(of: "#", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard let color = UIColor(hexString: code) else { return }
                mainStore.dispatch(AppAction.addColor(color))
                HUD.flash(.success, delay: 0.5)
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
}

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        PKHUD.sharedHUD.dimsBackground = false
        HUD.show(.progress)
        DispatchQueue.global().async {
            let colors = ColorsFromImage(image, withFlatScheme: false)
            DispatchQueue.main.async {
                mainStore.dispatch(AppAction.addColors(colors))
                HUD.flash(.success, delay: 0.5)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
