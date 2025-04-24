//
//  HomeViewControllerTests.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/05/04.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import XCTest

@testable import Gradientor

class HomeViewControllerTests: XCTestCase {

    let homeViewController = HomeViewController()

    var presentedViewController: UIViewController? {
        return homeViewController.presentedViewController
    }
    var topViewController: UIViewController? {
        return (presentedViewController as? UINavigationController)?.topViewController
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AppState.shared.colors = []
        let navigationController = UINavigationController(rootViewController: homeViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
        _ = homeViewController.view
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewDidLoad() {
        let expectation = self.expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(AppState.shared.colors.count, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - Utilities

    func testSetIconColors() {
        homeViewController.setIconColors()
        XCTAssertEqual(AppState.shared.colors.count, 3)
    }

    func testUpdateGradient() {
        AppState.shared.direction = .vertical
        homeViewController.viewWillAppear(false)
        XCTAssertEqual(homeViewController.gradient.direction, .vertical)

        AppState.shared.direction = .radial
        homeViewController.viewWillAppear(false)
        XCTAssertEqual(homeViewController.gradient.direction, .radial)

        AppState.shared.direction = .diagonalLR
        homeViewController.viewWillAppear(false)
        XCTAssertEqual(homeViewController.gradient.direction, .diagonalLR)

        AppState.shared.direction = .diagonalRL
        homeViewController.viewWillAppear(false)
        XCTAssertEqual(homeViewController.gradient.direction, .diagonalRL)
    }

    // MARK: - Actions

    func testEditDidTap() {
        let editItem = homeViewController.editItem
        UIApplication.shared.sendAction(editItem.action!, to: editItem.target, from: nil, for: nil)

        let expectation = self.expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.homeViewController.navigationController?.topViewController is EditViewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testInfoDidTap() {
        let infoItem = homeViewController.infoItem
        UIApplication.shared.sendAction(infoItem.action!, to: infoItem.target, from: nil, for: nil)

        XCTAssertTrue((presentedViewController as? UINavigationController)?.topViewController is AboutViewController)
    }

    func testClearDidTap() {
        let clearItem = homeViewController.clearItem
        UIApplication.shared.sendAction(clearItem.action!, to: clearItem.target, from: nil, for: nil)

        XCTAssertTrue(presentedViewController is UIAlertController)
        XCTAssertEqual(presentedViewController?.title, "Delete All Colors")
    }

    func testRefreshDidTap() {
        let refreshItem = homeViewController.refreshItem
        UIApplication.shared.sendAction(refreshItem.action!, to: refreshItem.target, from: nil, for: nil)

        XCTAssertTrue(presentedViewController is UIAlertController)
        XCTAssertEqual(presentedViewController?.title, "Recreate Colors")
    }

    func testExportDidTap() {
        let exportItem = homeViewController.exportItem
        UIApplication.shared.sendAction(exportItem.action!, to: exportItem.target, from: nil, for: nil)

        XCTAssertTrue(topViewController is ExportViewController)

        (topViewController as? ExportViewController)?.didClose()

        let expectation = self.expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNil(self.topViewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
