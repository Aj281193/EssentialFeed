//
//  XCTestCase+FailableRetriveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 10/01/23.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetriveDeliversFailureOnRetrivalError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrive: .failure(anyNSError()),file: file,line: line)
    }
    
    func assertThatRetriveHasNoSideEffectsOnfailure(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetriveTwice: .failure(anyNSError()),file: file,line: line)
    }
    
}
