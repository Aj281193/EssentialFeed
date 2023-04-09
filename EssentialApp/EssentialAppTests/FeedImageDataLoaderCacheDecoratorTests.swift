//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import XCTest
import EssentialFeed

class FeedImageLoaderCacheDecorator: FeedImageDataLoader {
    
    let decoratee: FeedImageDataLoader
    let imageCache: FeedImageCache
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.imageCache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { imageData in
                self?.imageCache.save(imageData, for: url) { _ in }
                return imageData
            })
        }
        return task
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoadderTestCase {

    func test_init_doesNotLoadImageData() {
      
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URL's")
    }
    
    func test_loadImageData_loadFromLoader() {
        let url = anyURL()
        let (sut,loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URLs from loader")
    }
    
    func test_cancelLoadImageData_cancelLoaderTask() {
        let url = anyURL()
        let (sut,loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = anyData()
        let (sut,loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliverFailureOnLoaderFailure() {
        let error = anyNSError()
        let (sut,loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(error)) {
            loader.complete(with: error)
        }
    }
    
    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let url = anyURL()
        let cache = CacheSpy()
        let imageData = anyData()
        let (sut,loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)],"Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let url = anyURL()
        let cache = CacheSpy()
        let error = anyNSError()
        let (sut,loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        loader.complete(with: error)
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache image data on load error")
    }
    
    //MARK Helpers:-
    
    private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader,loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
    
    private class CacheSpy: FeedImageCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data: data, for: url))
            completion(.success(()))
        }
    }
}
