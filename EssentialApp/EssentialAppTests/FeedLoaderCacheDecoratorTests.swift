//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 08/04/23.
//

import XCTest
import EssentialFeed

class FeedLoaderCacheDecorator: FeedLoader {
 
    let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(.success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = FeedLoaderStub(.failure(anyNSError()))
        
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    //MARK Helpers
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result,file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
    
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure,.failure): break
            default:
                XCTFail("Expected \(expectedResult) result got received \(receivedResult) result instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
