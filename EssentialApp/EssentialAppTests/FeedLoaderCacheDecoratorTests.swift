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
        let loader = LoaderStub(.success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = LoaderStub(.failure(anyNSError()))
        
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
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
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(_ result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
