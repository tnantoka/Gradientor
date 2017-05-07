//
//  AddViewControllerTests.swift
//  Gradientor
//
//  Created by Tatsuya Tobioka on 2017/05/04.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import XCTest

@testable import Gradientor

class AddViewControllerTests: XCTestCase {

    let addViewController = AddViewController()

    var presentedViewController: UIViewController? {
        return addViewController.presentedViewController
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let navigationController = UINavigationController(rootViewController: addViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewDidLoad() {
        guard let collectionView = addViewController.view.subviews[0] as? UICollectionView else { fatalError() }
        let numberOfItems = collectionView.dataSource!.collectionView(collectionView, numberOfItemsInSection: 0)
        XCTAssertEqual(numberOfItems, 20)
    }

    // MARK - Actions

    func testRandomDidTap() {
        let randomItem = addViewController.randomItem
        UIApplication.shared.sendAction(randomItem.action!, to: randomItem.target, from: nil, for: nil)

        XCTAssertEqual(mainStore.state.colors.count, 3)
    }

    func testRGBDidTap() {
        let rgbItem = addViewController.rgbItem
        UIApplication.shared.sendAction(rgbItem.action!, to: rgbItem.target, from: nil, for: nil)

        XCTAssertTrue(presentedViewController is UIAlertController)
        XCTAssertEqual(presentedViewController?.title, "Add Color")
    }

    func testImageDidTap() {
        let imageItem = addViewController.imageItem
        UIApplication.shared.sendAction(imageItem.action!, to: imageItem.target, from: nil, for: nil)

        XCTAssertTrue(presentedViewController is UIImagePickerController)
    }
}
