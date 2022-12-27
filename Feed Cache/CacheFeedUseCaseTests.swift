//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 26/12/22.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore,currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItems], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}
class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
        
    enum ReceviedMessage: Equatable {
        case deleteCacheFeed
        case insert([FeedItems],Date)
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
    
    func insert(_ items: [FeedItems], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessgae.append(.insert(items, timestamp))
    }
}
final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessgae, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items) { _ in }
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullyDeletion() {
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed,.insert(items, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?,deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let insertionError = anyNSError()
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?,insertionError)
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedError)
    }
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }
    
    private func uniqueItem() -> FeedItems {
        return FeedItems(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return  URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
