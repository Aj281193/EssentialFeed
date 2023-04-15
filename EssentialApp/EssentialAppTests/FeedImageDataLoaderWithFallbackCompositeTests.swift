//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 07/04/23.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoadderTestCase {

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
    
    func test_cancelLoadImageData_cancelPrimaryLoaderTask() {
        let url = anyURL()
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URLs loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs loading in the fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()

        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let primaryData = anyData()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success(primaryData)) {
            primaryLoader.complete(with: primaryData)
        }

    }
    
    func test_loadImageData_deliverFallbackDataOnFllbackLoaderSuccess() {
        let fallbackData = anyData()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(fallbackData)) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        }
    }
    
    func test_loadImageData_deliverErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        }
    }
    
    //MARK Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader,primary: FeedImageDataLoaderSpy, fallback: FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file: file ,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file, line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,primaryLoader,fallbackLoader)
    }
}
