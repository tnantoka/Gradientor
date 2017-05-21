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

    lazy internal var closeItem: UIBarButtonItem = {
        self.barButtomItem(title: NSLocalizedString("Close", comment: ""), bag: self.bag) { [weak self] _ in
            self?.closeDidTap()
        }
    }()
    lazy internal var saveItem: UIBarButtonItem = {
        self.barButtomItem(systemItem: .save, bag: self.bag) { [weak self] _ in
            self?.saveDidTap()
        }
    }()

    lazy private var widthRow: IntRow = {
        IntRow { row in
            row.title = NSLocalizedString("Width", comment: "")
            row.add(rule: RuleGreaterThan(min: 0))
            row.value = Int(mainStore.state.exportSize.width)
            row.formatter = nil
            row.disabled = Condition.function(["preset"]) { form in
                guard let row = form.rowBy(tag: "preset") as? ActionSheetRow<String> else { return false }
                return row.value != NSLocalizedString("None", comment: "")
            }
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
    }()
    lazy private var heightRow: IntRow = {
        IntRow { row in
            row.title = NSLocalizedString("Height", comment: "")
            row.add(rule: RuleGreaterThan(min: 0))
            row.value = Int(mainStore.state.exportSize.height)
            row.formatter = nil
            row.disabled = Condition.function(["preset"]) { form in
                guard let row = form.rowBy(tag: "preset") as? ActionSheetRow<String> else { return false }
                return row.value != NSLocalizedString("None", comment: "")
            }
        }
        .onChange { row in
            guard let height = row.value else { return }
            var size = mainStore.state.exportSize
            size.height = CGFloat(height)
            mainStore.dispatch(AppAction.setExportSize(size))
        }
        .cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
    }()
    lazy private var sizeSection: Section = {
        Section(NSLocalizedString("Size", comment: "")) { section in
            section.append(self.widthRow)
            section.append(self.heightRow)
            section.append(
                ActionSheetRow<String>("preset") { row in
                    let none = NSLocalizedString("None", comment: "")
                    row.title = NSLocalizedString("Preset", comment: "")
                    row.options = [none] + Preset.names
                    row.value = none
                }
                .onChange { [weak self] row in
                    guard let name = row.value else { return }
                    guard let index = Preset.names.index(of: name) else { return }
                    let size = Preset.sizes[index]
                    self?.widthRow.value = Int(size.width)
                    self?.heightRow.value = Int(size.height)
                    mainStore.dispatch(AppAction.setExportSize(size))
                }
            )
        }
    }()

    lazy private var optionsSection: Section = {
        Section(NSLocalizedString("Options", comment: "")) { section in
            section.append(
                SwitchRow("image") { row in
                    row.title = NSLocalizedString("Image", comment: "")
                    row.value = mainStore.state.isExportImage
                }
                .onChange { [weak self] row in
                    guard let value = row.value else { return }
                    mainStore.dispatch(AppAction.setIsExportImage(value))
                    self?.updateUI()
                }
            )
            section.append(
                SwitchRow("text") { row in
                    row.title = NSLocalizedString("Text", comment: "")
                    row.value = mainStore.state.isExportText
                }
                .onChange { [weak self] row in
                    guard let value = row.value else { return }
                    mainStore.dispatch(AppAction.setIsExportText(value))
                    self?.updateUI()
                }
            )
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Export", comment: "")
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.rightBarButtonItem = saveItem

        tableView.backgroundColor = MaterialDesign.backgroundColor
        tableView.separatorColor = .clear

        form.append(sizeSection)
        form.append(optionsSection)
    }

    // MARK - Utilities

    private func updateUI() {
        saveItem.isEnabled = mainStore.state.isExportImage || mainStore.state.isExportText
    }

    private func saveToDocs(gradient: Gradient) {
        guard let docs = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else { return }
        let name = (form.rowBy(tag: "preset") as? ActionSheetRow<String>)?.value ?? "preset"

        let imageURL = docs.appendingPathComponent("\(name).png")
        guard let data = UIImagePNGRepresentation(gradient.image) else { return }
        try? data.write(to: imageURL)

        let textURL = docs.appendingPathComponent("\(name).txt")
        try? gradient.text.write(to: textURL, atomically: true, encoding: .utf8)

        print(docs.absoluteString)
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
        gradient.frame = CGRect(origin: .zero, size: mainStore.state.exportSize)

        #if DEBUG
//            saveToDocs(gradient: gradient); let fixme = ""
        #endif

        if mainStore.state.isExportImage {
            items.append(gradient.image)
        }
        if mainStore.state.isExportText {
            items.append(gradient.text)
        }
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)

        mainStore.dispatch(AppAction.incrementExportCount)
    }
}
