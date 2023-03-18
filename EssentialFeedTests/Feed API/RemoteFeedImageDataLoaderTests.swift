//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 15/03/23.
//

import XCTest
import EssentialFeed

final class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let(_,client) = makeSUT()
        XCTAssertTrue(client.requestedURL.isEmpty)
    }

    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url])
    }
    
    func test_loadImageDataFromURL_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url,url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut,client) = makeSUT()
        let clientError = NSError(domain: "a clientError", code: 0)
        
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: clientError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index,code in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
        
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HttpResponse() {
        let (sut,client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyReceivedDataOn200HTTPResponse() {
        let (sut,client) = makeSUT()
        let nonemptyData = Data("non-empty data".utf8)
        
        expect(sut: sut, toCompleteWith: .success(nonemptyData)) {
            client.complete(withStatusCode: 200, data: nonemptyData)
        }
        
    }
    
    func test_loadImageDatFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var captureResult = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) {
            captureResult.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(captureResult.isEmpty)
    }
 
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut,client) = makeSUT()
        let url = URL(string: "https://a-given-url-com")!
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancel URL Request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL after the task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut,client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var received = [FeedImageDataLoader.Result]()
        
        let task = sut.loadImageData(from: anyURL()) {  received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received result after cancelling task")
    }
    
    //MARK: Helper
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(client,file: file,line: line)
        trackForMemoryLeak(sut,file: file,line: line)
        return (sut,client)
    }
        
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: url) { receivedResult in
            switch(receivedResult,expectedResult) {
            case let(.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
            case let(.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
