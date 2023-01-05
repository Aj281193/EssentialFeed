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
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
           return completion(.empty) }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}
final class CodableFeedStoreTests: XCTestCase {

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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL)
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    var testSpecificStoreURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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