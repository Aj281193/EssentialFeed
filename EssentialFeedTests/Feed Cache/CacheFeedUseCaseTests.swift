//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 26/12/22.
//

import XCTest
import EssentialFeed

private class FeedStoreSpy: FeedStore {

    enum ReceviedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage],Date)
    }
    
    private(set) var receivedMessgae = [ReceviedMessage]()
    
    private var deleteCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCompletion.append(completion)
        receivedMessgae.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletion[index](nil)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessgae.append(.insert(feed, timestamp))
    }
}
final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessgae, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut,store) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullyDeletion() {
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let feed = uniqueImageFeed()
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed,.insert(feed.local, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let (sut,store) = makeSUT()
         
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDelieverDelitionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.saveResult]()
        
        sut?.save(uniqueImageFeed().models) {
            receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDelieverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [Error?]()
        
        sut?.save(uniqueImageFeed().models) {
            receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }
   
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
       action()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?,expectedError, file: file,line: line)
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
