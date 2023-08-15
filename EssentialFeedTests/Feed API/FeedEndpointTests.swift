//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/08/23.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
   
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndPoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/feed")!
        
        XCTAssertEqual(received, expected)
    }
}
