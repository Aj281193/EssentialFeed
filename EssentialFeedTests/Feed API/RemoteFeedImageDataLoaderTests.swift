//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 15/03/23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}
final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let(_,client) = makeSUT()
        XCTAssertTrue(client.requestedURL.isEmpty)
    }

    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(client,file: file,line: line)
        trackForMemoryLeak(sut,file: file,line: line)
        return (sut,client)
    }
    
    private class HTTPClientSpy {
      var requestedURL = [URL]()
    }
}
