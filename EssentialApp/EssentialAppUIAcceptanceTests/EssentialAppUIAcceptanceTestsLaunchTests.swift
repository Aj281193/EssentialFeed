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
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
}
