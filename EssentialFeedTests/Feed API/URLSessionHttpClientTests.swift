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
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _,_,error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHttpClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "Test", code: 1)
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)

        let sut = URLSessionHttpClient()
        //since it is asynchronous
        let exp = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedEror as NSError):
                XCTAssertEqual(receivedEror.domain, error.domain)
                XCTAssertEqual(receivedEror.code, error.code)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }

   // MARK:- Helpers
    private class URLProtocolStub: URLProtocol {
       
        private static var stub: Stub?
        
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
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
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
