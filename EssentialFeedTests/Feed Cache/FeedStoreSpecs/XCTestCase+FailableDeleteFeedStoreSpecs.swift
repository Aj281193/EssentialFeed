//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 10/01/23.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError,"Expected cache delition to fail",file: file,line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .success(.empty), file: file,line: line)
    }
    
}
