//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 31/12/22.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessgae, [])
    }
    
    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut,store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessgae, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_doesNotdeleteCacheOnEmptyCache() {
        let (sut,store) = makeSUT()
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessgae, [.retrieve])
    }
    
    func test_validateCache_doesNotdeleteOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessgae, [.retrieve])
    }
    
    func test_validateCache_deleteOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
        
        XCTAssertEqual(store.receivedMessgae, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_deleteOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessgae, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessgae, [.retrieve])
    }
    
    //MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }

}

