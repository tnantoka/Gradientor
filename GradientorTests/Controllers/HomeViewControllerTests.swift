//
//  HomeViewControllerTests.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/05/04.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import XCTest

@testable import Gradientor
import RFAboutView_Swift

class HomeViewControllerTests: XCTestCase {

    let homeViewController = HomeViewController()

    var presentedViewController: UIViewController? {
        return homeViewController.presentedViewController
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let navigationController = UINavigationController(rootViewController: homeViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewDidLoad() {
        XCTAssertEqual(mainStore.state.colors.count, 2)
    }

    // MARK: - Actions

    func testEditDidTap() {
        homeViewController.editDidTap()

        let expectation = self.expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.homeViewController.navigationController?.topViewController is EditViewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testInfoDidTap() {
        homeViewController.infoDidTap()

        XCTAssertTrue((presentedViewController as? UINavigationController)?.topViewController is RFAboutViewController)
    }

    func testClearDidTap() {
        homeViewController.clearDidTap()

        XCTAssertTrue(presentedViewController is UIAlertController)
        XCTAssertEqual(presentedViewController?.title, "Delete All Colors")
    }

    func testRefreshDidTap() {
        homeViewController.refreshDidTap()

        XCTAssertTrue(presentedViewController is UIAlertController)
        XCTAssertEqual(presentedViewController?.title, "Recreate Colors")
    }

    func testExportDidTap() {
        homeViewController.exportDidTap()

        XCTAssertTrue((presentedViewController as? UINavigationController)?.topViewController is ExportViewController)
    }
}
