//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 10/01/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetriveDeliversEmptyOnEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: .empty, file: file ,line: line)
    }
    
    func assertThatRetriveHasNoSideEffectsOnEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetriveTwice: .empty, file: file ,line: line)
    }
    
    func assertThatRetriveDeliversFoundValueOnNonEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp), file: file ,line: line)
    }
    
    func assertThatInsertOveridesPreviouslyInsertedCacheValue(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed,latestTimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to overide cache successfully")
        
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestTimeStamp), file: file ,line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully",file: file,line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty,file: file,line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func  assertThatSideEffetsRunSerially(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completeOperationInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completeOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            completeOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completeOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completeOperationInOrder, [op1,op2,op3], "Expected side-effects to run serially but operations finished in wrong order",file: file,line: line)
    }
    
    func asssertThatRetriveHasNoSideEffectsOnNonEmptyCache(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func assertThatRetriveDeliversFailureOnRetrivalError(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: .failure(anyNSError()),file: file,line: line)
    }
    
    func assertThatRetriveHasNoSideEffectsOnfailure(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetriveTwice: .failure(anyNSError()),file: file,line: line)
    }
    
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
