//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 05/01/23.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_retrive_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetriveTwice: .empty)
    }
    
    func test_retrive_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrive_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetriveTwice: .found(feed: feed, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let sut = makeSUT()
        
        try! "InvalidData".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let sut = makeSUT()
        
        try! "InvalidData".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overidesPreviouslyInsertedCacheValue() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed,latestTimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to overide cache successfully")
        
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestTimeStamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        let insertionError = insert((feed, timeStamp: timeStamp), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected cache insertion to fail with an error")
        
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
         insert((feed, timeStamp: timeStamp), to: sut)
        
        expect(sut, toRetrive: .empty)
        
    }

    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError,"Expected non empty cache deletion to suceed")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError,"Expected non empty cache deletion to suceed")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDelePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDelePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError,"Expected cache delition to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDelePermissionURL = cacheDirectory()
        let sut = makeSUT(storeURL: noDelePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
        
        XCTAssertEqual(completeOperationInOrder, [op1,op2,op3], "Expected side-effects to run serially but operations finished in wrong order")
    }
    
    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    
    var testSpecificStoreURL: URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func  setupEmptyStoreState() {
        deleteStoreArtifact()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifact()
    }
    
    private func deleteStoreArtifact() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
