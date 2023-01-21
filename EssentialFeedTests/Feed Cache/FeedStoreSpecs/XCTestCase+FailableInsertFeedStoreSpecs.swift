//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 10/01/23.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversErrorOnInsertionError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        let insertionError = insert((feed, timeStamp: timeStamp), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected cache insertion to fail with an error",file: file,line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp: timeStamp), to: sut)
        
        expect(sut, toRetrive: .success(.none),file: file,line: line)
    }
    
}
