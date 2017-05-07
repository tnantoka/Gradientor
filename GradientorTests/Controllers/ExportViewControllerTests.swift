//
//  ExportViewControllerTests.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/05/04.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import XCTest

@testable import Gradientor
import Eureka

class ExportViewControllerTests: XCTestCase {

    let exportViewController = ExportViewController()

    var presentedViewController: UIViewController? {
        return exportViewController.presentedViewController
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let navigationController = UINavigationController(rootViewController: exportViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewDidLoad() {
        let exportViewController = ExportViewController()
        _ = exportViewController.view
        let numberOfSections = exportViewController.form.allSections.count
        XCTAssertEqual(numberOfSections, 2)
    }

    // MARK - Actions

    func testCloseDidTap() {
        exportViewController.didClose = {
            XCTAssertTrue(true)
        }
        let closeItem = exportViewController.closeItem
        UIApplication.shared.sendAction(closeItem.action!, to: closeItem.target, from: nil, for: nil)
    }

    func testSaveDidTap() {
        let saveItem = exportViewController.saveItem
        UIApplication.shared.sendAction(saveItem.action!, to: saveItem.target, from: nil, for: nil)
        XCTAssertTrue(presentedViewController is UIActivityViewController)
    }
}
