//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 08/04/23.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTests: XCTestCase {}

extension FeedLoaderTests {
     func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result,file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
    
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure,.failure): break
            default:
                XCTFail("Expected \(expectedResult) result got received \(receivedResult) result instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
