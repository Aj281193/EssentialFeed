//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 01/07/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = WindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }
    
    func test_configureWindow_ConfigureRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        
        XCTAssertNotNil(rootNavigation,"Expected the navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController,"Expected the top controller as top view controller, got \(String(describing: topController)) instead")
        
    }
}
private class WindowSpy: UIWindow {
    var makeKeyAndVisibleCallCount = 0
    
    override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount = 1
    }
}
