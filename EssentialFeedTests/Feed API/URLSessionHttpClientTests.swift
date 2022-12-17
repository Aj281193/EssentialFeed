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
    
    init(session: URLSession) {
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

   
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)

        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Test", code: 1)
        
        session.stub(url: url, error: error)

        let sut = URLSessionHttpClient(session: session)
        //since it is asynchronous
        let exp = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedEror as NSError):
                XCTAssertEqual(receivedEror, error)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

   // MARK:- Helpers
    private class URLSessionSpy: URLSession {
       
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, error: Error? = nil, task: URLSessionDataTask = FakeURLSessionData()) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            guard let stub = stubs[url]  else {
                fatalError("couldn't find stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionData: URLSessionDataTask {
        override func resume() {
            
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
        
    }
}
