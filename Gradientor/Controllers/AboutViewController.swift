//
//  AboutViewController.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2025/04/19.
//  Copyright © 2025 tnantoka. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {
  let reuseIdentifier = "reuseIdentifier"

  let dependencies = [
    [
      "AdFooter",
      "https://gitlab.com/tnantoka/AdFooter",
    ],
    [
      "Chameleon",
      "https://github.com/vicc/chameleon",
    ],
    [
      "Eureka",
      "https://github.com/xmartlabs/Eureka",
    ],
    [
      "MaterialDesignColorPicker",
      "https://github.com/CodeCatalyst/MaterialDesignColorPicker",
    ],
  ]

  var closeItem: UIBarButtonItem {
    return UIBarButtonItem(
      title: NSLocalizedString("Close", comment: ""),
      style: .plain,
      target: self,
      action: #selector(closeItemDidTap)
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = closeItem

    title = NSLocalizedString("About", comment: "")

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
  }

  @objc func closeItemDidTap(sender: Any?) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}

extension AboutViewController /*: UITableViewDataSource, UITableViewDelegate*/ {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return dependencies.count
    default:
      return 0
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  {
    switch section {
    case 1:
      return NSLocalizedString("Acknowledgements", comment: "")
    default:
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
  {
    switch section {
    case 1:
      return "© 2025 tnantoka"
    default:
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    cell.accessoryType = .disclosureIndicator

    switch indexPath.section {
    case 0:
      cell.textLabel?.text = "Gradientor"
      cell.detailTextLabel?.text = "http://gradientor.tnantoka.com/"
      break
    case 1:
      cell.textLabel?.text = dependencies[indexPath.row][0]
      cell.detailTextLabel?.text = dependencies[indexPath.row][1]
      break
    default:
      break
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      let url = URL(string: "http://gradientor.tnantoka.com/")!
      UIApplication.shared.open(url)
      break
    case 1:
      let url = URL(string: dependencies[indexPath.row][1])!
      UIApplication.shared.open(url)
      break
    default:
      break
    }

    tableView.deselectRow(at: indexPath, animated: true)
  }
}
