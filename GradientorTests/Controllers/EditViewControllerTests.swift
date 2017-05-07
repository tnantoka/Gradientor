//
//  EditViewControllerTests.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/05/04.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import XCTest

@testable import Gradientor

class EditViewControllerTests: XCTestCase {

    let editViewController = EditViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let navigationController = UINavigationController(rootViewController: editViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewDidLoad() {
        let tableView = editViewController.tableView!
        let numberOfRows = tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, mainStore.state.colors.count)
    }

    // MARK - Actions

    func testAddDidTap() {
        let addItem = editViewController.addItem
        UIApplication.shared.sendAction(addItem.action!, to: addItem.target, from: nil, for: nil)

        let expectation = self.expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.editViewController.navigationController?.topViewController is AddViewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
