//
//  EssentialAppUIAcceptanceTestsLaunchTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Ashish Jaiswal on 15/04/23.
//

import XCTest

final class EssentialAppUIAcceptanceTestsLaunchTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomeHasConnectivity() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
