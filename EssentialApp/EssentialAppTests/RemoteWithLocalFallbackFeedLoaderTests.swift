//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 07/04/23.
//

import XCTest
import EssentialFeed


class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}
final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
       
        let exp = expectation(description: "Wait for load completion")
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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



