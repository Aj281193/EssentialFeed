//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doestNotLoadDataFromURL() {
        let (_, client) = makeSut()
        XCTAssertTrue(client.requestedURL.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-u.com")!
        let (sut,client) = makeSut(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURL,[url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-u.com")!
        let (sut,client) = makeSut(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURL, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut,client) = makeSut()
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,client) = makeSut()

        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn200HTTPResponseWithInvalidJson() {
        let (sut,client) = makeSut()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data("InvalidJson".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
 
    
    // MARK:- Helpers
    private func makeSut(url: URL =  URL(string: "https://a-u.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var captureError = [RemoteFeedLoader.Error]()
        sut.load { captureError.append($0) }
        action()
        XCTAssertEqual(captureError, [error], file: file, line: line)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
    
        private var messages = [(url: URL, completion: (HTTPResponseResult) -> Void)]()
        
        var requestedURL: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPResponseResult) -> Void) {
            messages.append((url,completion))
         }
         
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data() , at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURL[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data,response))
        }
     }

}

