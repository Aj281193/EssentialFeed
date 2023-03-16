//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 15/03/23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return HTTPTaskWrapper(wrapped:
            client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case  let .success((data,response)):
                if response.statusCode == 200 , !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error): completion(.failure(error))
            }
        })
    }
}
final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let(_,client) = makeSUT()
        XCTAssertTrue(client.requestedURL.isEmpty)
    }

    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url])
    }
    
    func test_loadImageDataFromURL_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURL, [url,url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        let clientError = NSError(domain: "a clientError", code: 0)
        
        expect(sut: sut, toCompleteWith: .failure(clientError)) {
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
        sut?.loadImageData(from: anyURL()) {
            captureResult.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(captureResult.isEmpty)
    }
 
    //MARK: Helper
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(client,file: file,line: line)
        trackForMemoryLeak(sut,file: file,line: line)
        return (sut,client)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
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
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        private struct Task: HTTPClientTask {
            func cancel() { }
        }
        
        var requestedURL: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url,completion))
            return Task()
        }
        
        func post(_ data: Data, to url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURL[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
