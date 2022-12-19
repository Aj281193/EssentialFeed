//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentaion: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data,response,error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data , let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentaion()))
            }
        }.resume()
    }
}


class URLSessionHttpClientTests: XCTestCase {

    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        
        let requestError = anyError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.domain , requestError.domain)
        
    }

    func test_getFromURL_failsOnAllInvalidRepresentableTestCases() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response:nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedOnHTTPURLResponseWithData() {
        URLProtocolStub.stub(data: anyData(), response: anyHTTPURLResponse(), error: nil)
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
              case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, self.anyData())
                XCTAssertEqual(receivedResponse.url, self.anyHTTPURLResponse().url)
                XCTAssertEqual(receivedResponse.statusCode, self.anyHTTPURLResponse().statusCode)
            default:
                XCTFail("Expected success got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHttpURLResponseWithNilData() {
        URLProtocolStub.stub(data: nil, response: anyHTTPURLResponse(), error: nil)
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
              case let .success(receivedData, receivedResponse):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedResponse.url, self.anyHTTPURLResponse().url)
                XCTAssertEqual(receivedResponse.statusCode, self.anyHTTPURLResponse().statusCode)
            default:
                XCTFail("Expected success got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
   // MARK:- Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackForMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return  URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        return  Data("any-data".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file,line: line)
        let exp = expectation(description: "wait for expectation")
        
        var receivedError: Error?
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure got \(result) instead", file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private class URLProtocolStub: URLProtocol {
       
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
          
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
             
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
}
