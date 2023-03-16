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
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
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
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(client,file: file,line: line)
        trackForMemoryLeak(sut,file: file,line: line)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURL.append(url)
        }
        
        func post(_ data: Data, to url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
        }
    }
}
