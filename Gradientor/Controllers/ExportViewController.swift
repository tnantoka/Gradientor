//
//  ExportViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/27.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import Eureka
import ChameleonFramework
import RxSwift

class ExportViewController: FormViewController {

    var didClose: () -> Void = {}

    let bag = DisposeBag()

    lazy private var closeItem: UIBarButtonItem = {
        let closeItem = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: ""),
            style: .plain,
            target: nil,
            action: nil
        )

        closeItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.closeDidTap()
            })
            .addDisposableTo(self.bag)
        return closeItem
    }()
    lazy private var saveItem: UIBarButtonItem = {
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

        saveItem.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.saveDidTap()
            })
            .addDisposableTo(self.bag)
        return saveItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Export", comment: "")
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.rightBarButtonItem = saveItem

        tableView.backgroundColor = UIColor(hexString: "#FAFAFA")
        tableView.separatorColor = .clear

        form.append(
            Section(NSLocalizedString("Size", comment: "")) { section in
                let widthRow = IntRow { row in
                    row.title = NSLocalizedString("Width", comment: "")
                    row.add(rule: RuleGreaterThan(min: 0))
                    row.value = Int(mainStore.state.exportSize.width)
                    row.formatter = nil
                }
                .onChange { row in
                    guard let width = row.value else { return }
                    var size = mainStore.state.exportSize
                    size.width = CGFloat(width)
                    mainStore.dispatch(AppAction.setExportSize(size))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }

                let heightRow = IntRow { row in
                    row.title = NSLocalizedString("Height", comment: "")
                    row.add(rule: RuleGreaterThan(min: 0))
                    row.value = Int(mainStore.state.exportSize.height)
                    row.formatter = nil
                }
                .onChange { row in
                    guard let height = row.value else { return }
                    var size = mainStore.state.exportSize
                    size.width = CGFloat(height)
                    mainStore.dispatch(AppAction.setExportSize(size))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }

                section.append(widthRow)
                section.append(heightRow)
                section.append(
                    ActionSheetRow<String> { row in
                        let none = NSLocalizedString("None", comment: "")
                        row.title = NSLocalizedString("Preset", comment: "")
                        row.options = [none] + Preset.names
                        row.value = none
                    }
                    .onChange { row in
                        guard let name = row.value else { return }
                        guard let index = Preset.names.index(of: name) else { return }
                        let size = Preset.sizes[index]
                        widthRow.value = Int(size.width)
                        heightRow.value = Int(size.height)
                        mainStore.dispatch(AppAction.setExportSize(size))
                    }
                )
            }
        )

        form.append(
            Section(NSLocalizedString("Options", comment: "")) { section in
                section.append(
                    SwitchRow { row in
                        row.title = NSLocalizedString("Image", comment: "")
                        row.value = mainStore.state.isExportImage
                    }
                    .onChange { row in
                        guard let value = row.value else { return }
                        mainStore.dispatch(AppAction.setIsExportImage(value))
                    }
                )
                section.append(
                    SwitchRow { row in
                        row.title = NSLocalizedString("Text", comment: "")
                        row.value = mainStore.state.isExportText
                    }
                    .onChange { row in
                        guard let value = row.value else { return }
                        mainStore.dispatch(AppAction.setIsExportText(value))
                    }
                )
            }
        )
    }

    // MARK - Actions

    private func closeDidTap() {
        didClose()
    }

    private func saveDidTap() {
        var items = [Any]()

        var gradient = Gradient()
        gradient.direction = mainStore.state.direction
        gradient.colors = mainStore.state.colors
        gradient.frame = CGRect(origin: CGPoint.zero, size: mainStore.state.exportSize)

        if mainStore.state.isExportImage {
            items.append(gradient.image)
        }
        if mainStore.state.isExportText {
            items.append(gradient.colors.map { $0.hexValue() }.joined(separator: ", "))
        }
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)

        mainStore.dispatch(AppAction.incrementExportCount)
    }
}
