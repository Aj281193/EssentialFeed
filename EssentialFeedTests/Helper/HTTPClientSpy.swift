//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 19/03/23.
//

import Foundation
import EssentialFeed

 class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var cancelledURLs = [URL]()
    private struct Task: HTTPClientTask {
        var callback: () -> Void
        func cancel() { callback() }
    }
    
    var requestedURL: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url,completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURL[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
