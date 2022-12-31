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
    
    func test_validateCache_doesNotdeleteCacheOnLessThanSevendaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(),uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (models,local)
    }
    
    private func anyURL() -> URL {
        return  URL(string: "https://any-url.com")!
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
