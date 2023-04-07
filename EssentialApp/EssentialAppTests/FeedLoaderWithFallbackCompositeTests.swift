//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 07/04/23.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
       
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliverFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliverErrorOnBothPrimaryAndFallbackLoaderFailure() {
        
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    //MARK - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result,file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
        let primaryLoader = LoaderStub(primaryResult)
        let fallbackLoader = LoaderStub(fallbackResult)
        
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeak(primaryLoader, file: file, line: line)
        trackForMemoryLeak(fallbackLoader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "ERROR", code: 0)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have beeen deallocated, potential memory leak.",file: file, line: line)
        }
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



