//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 10/01/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let exp = expectation(description: "wait for cache insertion")
        
        var insetionError: Error?
        sut.insert(cache.feed,timestamp: cache.timeStamp) { receiveInsertionError in
            insetionError = receiveInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insetionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        
        var deletionError: Error?
        
        sut.deleteCacheFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    
   func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrieveCaheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrive: expectedResult,file: file,line: line)
        expect(sut, toRetrive: expectedResult,file: file,line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: RetrieveCaheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { retriveResult in
            
            switch (expectedResult,retriveResult) {
            case (.empty,.empty),(.failure,.failure):
                break
                
            case let(.found(expectedFeed, expectedTimeStamp),.found(retrievedFeed, retriveTimeStamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed,file: file,line: line)
                XCTAssertEqual(expectedTimeStamp, retriveTimeStamp,file: file,line: line)
                
            default:
                XCTFail("Expected to retirve \(expectedResult) got \(retriveResult) instead",file: file,line: line)
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1.0)
    }
}
