//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 05/01/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
           return completion(.empty) }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timeStamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}
final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrive_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult,secondResult) {
                case (.empty,.empty):
                    break
                default:
                    XCTFail("Expected retrive twice from empty cache to deliver the same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retriveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        let exp = expectation(description: "wait for cache retrieval")
    
        sut.insert(feed,timestamp: timeStamp) { insertionError in
            XCTAssertNil(insertionError," Expected feed to be inserted Successfully")
            sut.retrieve { retriveResult in
                switch retriveResult {
                case let .found(retriveFeed,retriveTimeStamp):
                    XCTAssertEqual(retriveFeed, feed)
                    XCTAssertEqual(retriveTimeStamp, timeStamp)
                    break
                default:
                    XCTFail("Expected found result with feed \(feed) and timeStamp \(timeStamp) got \(retriveResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
