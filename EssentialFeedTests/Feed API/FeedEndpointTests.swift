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
        
        let received = FeedEndPoint.get().url(baseURL: baseURL)
     
        
        XCTAssertEqual(received.scheme, "http" ,"scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v1/feed", "path")
        XCTAssertEqual(received.query, "limit=10", "query")
    }
    
    func test_endpointURLAfterGivenImage() {
        let image = uniqueImage()
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndPoint.get(after: image).url(baseURL: baseURL)
     
        
        XCTAssertEqual(received.scheme, "http" ,"scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v1/feed", "path")
        XCTAssertEqual(received.query?.contains("limit=10"), true, "limit query param")
        XCTAssertEqual(received.query?.contains("after_id=\(image.id)"), true, "after_id query param")
       
    }
}
