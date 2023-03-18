//
//  URLProtocolStub.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 18/03/23.
//

import Foundation

 class URLProtocolStub: URLProtocol {
   
    private static var _stub: Stub?
    private static var stub: Stub? {
        get {
            queue.sync {
                return _stub
            }
        }
        set {
            queue.sync {
                _stub = newValue
            }
        }
    }
   
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    static func removeStub() {
        stub = nil
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    static func startInterceptingRequest() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
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
      
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
         
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.requestObserver?(request)
    }
    
    override func stopLoading() { }
}
