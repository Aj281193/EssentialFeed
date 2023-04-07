//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 07/04/23.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private var primary: FeedImageDataLoader
    private var fallback: FeedImageDataLoader
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url, completion: {[weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
               _ = self?.fallback.loadImageData(from: url, completion: completion)
                
            }
        })
        return Task()
    }
    
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
    
        let (_, primaryLoader,fallBackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URL's in the primary loader")
        XCTAssertTrue(fallBackLoader.loadedURLs.isEmpty, "Expected no loaded URL's in the fallback loader")
    }
    
    func test_loadImageData_loadFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url],"Expected to load URL from primary Loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty,"Expected no loaded urls in the fallback loader")
    }
    
    func test_loadImageData_loadFromFallbackOnPrimaryLoadFailure() {
        let url = anyURL()
        
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url],"Expected to load URL from primary Loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url],"Expected to load URL from fallback Loader")
    }
    
    //MARK Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader,primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file: file ,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file, line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,primaryLoader,fallbackLoader)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any ERROR", code: 0)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
            }
        }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return  messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            messages.append((url,completion))
            return Task()
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
