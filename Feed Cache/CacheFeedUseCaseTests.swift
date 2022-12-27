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
    
    func save(_ items: [FeedItems]) {
        store.deleteCacheFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}
class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
        
    enum ReceviedMessage: Equatable {
        case deleteCacheFeed
        case insert([FeedItems],Date)
    }
    
    private(set) var receivedMessgae = [ReceviedMessage]()
    
    private var deleteCompletion = [DeletionCompletion]()
    
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
    
    func insert(_ items: [FeedItems], timestamp: Date) {
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
        
        sut.save(items)
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullyDeletion() {
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessgae, [.deleteCacheFeed,.insert(items, timeStamp)])
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
