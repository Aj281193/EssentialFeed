//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retriveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "https://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoreDImageDataMatchingURL() {
        let sut = makeSUT()
        let storeData = anyData()
        
        let matchingURL = URL(string: "https://a-url.com")!
        
        insert(storeData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(storeData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoreData = Data("first".utf8)
        let lastStoreData = Data("last".utf8)
        
        let url = URL(string: "https://a-given-url")!
        insert(firstStoreData, for: url, into: sut)
        insert(lastStoreData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(lastStoreData), for: url)
        
    }
    
    // - MARK Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL,bundle: storeBundle)
        
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func notFound() ->  FeedImageDataStore.RetrievalResult  {
        return .success(.none)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        sut.completeRetrieval(dataFromURL: url) { receivedResult in
            switch(receivedResult,expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
            default:
                XCTFail("expected result \(expectedResult) got received result \(receivedResult)",file: file,line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any location", url: url)
    }
    
 
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("failed to insert data \(data) with \(error)",file: file,line: line)
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
