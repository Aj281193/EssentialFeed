//
//  FeedImageMapperTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 29/07/23.
//

import XCTest
import EssentialFeed

final class FeedImageMapperTests: XCTestCase {
  
    func test_map_throwErrorOnNon200HTTPResponse() throws {
      
        let samples = [199,201,300,400,500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversInvalidDataErrorOn200HttpResponseWithEmptyData() {
        let emptyData = Data()
        
        XCTAssertThrowsError(
            try FeedImageMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNonEmptyReceivedDataOn200HTTPResponse() throws {
        
        let nonemptyData = Data("non-empty data".utf8)
        
       let result = try FeedImageMapper.map(nonemptyData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, nonemptyData)
    }
    
}

