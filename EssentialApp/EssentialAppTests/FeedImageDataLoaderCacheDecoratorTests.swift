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
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = decoratee.loadImageData(from: url) { result in
            completion(result)
        }
        return task
    }
    
}
final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

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
    //MARK Helpers:-
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader,loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            case (.failure,.failure):
                break
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
}
