//
//  ExportViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/04/27.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import Eureka
import UIKit

class ExportViewController: FormViewController {

  var didClose: () -> Void = {}

  lazy internal var closeItem: UIBarButtonItem = {
    UIBarButtonItem(
      title: NSLocalizedString("Close", comment: ""),
      style: .plain,
      target: self,
      action: #selector(closeDidTap)
    )
  }()
  lazy internal var saveItem: UIBarButtonItem = {
    UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(saveDidTap)
    )
  }()

  lazy private var widthRow: IntRow = {
    IntRow { row in
      row.title = NSLocalizedString("Width", comment: "")
      row.add(rule: RuleGreaterThan(min: 0))
      row.value = Int(AppState.shared.exportSize.width)
      row.formatter = nil
      row.disabled = Condition.function(["preset"]) { form in
        guard let row = form.rowBy(tag: "preset") as? ActionSheetRow<String> else { return false }
        return row.value != NSLocalizedString("None", comment: "")
      }
    }
    .onChange { row in
      guard let width = row.value else { return }
      var size = AppState.shared.exportSize
      size.width = CGFloat(width)
      AppState.shared.exportSize = size
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
      row.value = Int(AppState.shared.exportSize.height)
      row.formatter = nil
      row.disabled = Condition.function(["preset"]) { form in
        guard let row = form.rowBy(tag: "preset") as? ActionSheetRow<String> else { return false }
        return row.value != NSLocalizedString("None", comment: "")
      }
    }
    .onChange { row in
      guard let height = row.value else { return }
      var size = AppState.shared.exportSize
      size.height = CGFloat(height)
      AppState.shared.exportSize = size
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
          AppState.shared.exportSize = size
        }
      )
    }
  }()

  lazy private var optionsSection: Section = {
    Section(NSLocalizedString("Options", comment: "")) { section in
      section.append(
        SwitchRow("image") { row in
          row.title = NSLocalizedString("Image", comment: "")
          row.value = AppState.shared.isExportImage
        }
        .onChange { [weak self] row in
          guard let value = row.value else { return }
          AppState.shared.isExportImage = value
          self?.updateUI()
        }
      )
      section.append(
        SwitchRow("text") { row in
          row.title = NSLocalizedString("Text", comment: "")
          row.value = AppState.shared.isExportText
        }
        .onChange { [weak self] row in
          guard let value = row.value else { return }
          AppState.shared.isExportText = value
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
    tableView.separatorStyle = .none

    form.append(sizeSection)
    form.append(optionsSection)
  }

  // MARK - Utilities

  private func updateUI() {
    saveItem.isEnabled = AppState.shared.isExportImage || AppState.shared.isExportText
  }

  private func saveToDocs(gradient: Gradient) {
    guard
      let docs = try? FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
      )
    else { return }
    let name = (form.rowBy(tag: "preset") as? ActionSheetRow<String>)?.value ?? "preset"

    let imageURL = docs.appendingPathComponent("\(name).png")
    guard let data = gradient.image.pngData() else { return }
    try? data.write(to: imageURL)

    let textURL = docs.appendingPathComponent("\(name).txt")
    try? gradient.text.write(to: textURL, atomically: true, encoding: .utf8)

    print(docs.absoluteString)
  }

  // MARK - Actions

  @objc private func closeDidTap() {
    didClose()
  }

  @objc private func saveDidTap() {
    var items = [Any]()

    var gradient = Gradient()
    gradient.direction = AppState.shared.direction
    gradient.colors = AppState.shared.colors
    gradient.frame = CGRect(origin: .zero, size: AppState.shared.exportSize)

    #if DEBUG
      //                  saveToDocs(gradient: gradient); let fixme = ""
    #endif

    if AppState.shared.isExportImage {
      items.append(gradient.image)
    }
    if AppState.shared.isExportText {
      items.append(gradient.text)
    }
    let activityViewController = UIActivityViewController(
      activityItems: items, applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)

    AppState.shared.exportCount += 1
  }
}
