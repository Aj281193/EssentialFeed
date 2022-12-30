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
  
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }
   
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
}
