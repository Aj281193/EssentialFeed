//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 30/12/22.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessgae, [])
    }
  
    func test_load_requestCacheRetrieval() {
        let (sut,store) = makeSUT()
        
        sut.load() { _ in }
        XCTAssertEqual(store.receivedMessgae, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut,store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, completeWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliverNoImageOnEmptyCache() {
        let (sut,store) = makeSUT()
        
        expect(sut, completeWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCacheImagesOnLessThanSevenDaysOld() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: { fixedCurrentDate })
        expect(sut, completeWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimeStamp)
        })
    }
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedImage), .success(expectedImage)):
                XCTAssertEqual(receivedImage, expectedImage,file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                  XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
           exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
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
