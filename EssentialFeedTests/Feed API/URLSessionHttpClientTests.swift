//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _,_,_ in }.resume()
    }
}
class URLSessionHttpClientTests: XCTestCase {

   
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)

        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }


   // MARK:- Helpers
    private class URLSessionSpy: URLSession {
       
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionData()
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
