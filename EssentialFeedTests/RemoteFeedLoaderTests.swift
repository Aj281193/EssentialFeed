//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

func test_init_doestNotLoadDataFromURL() {
   
    let (_, client) = makeSut()
    XCTAssertTrue(client.requestedURL.isEmpty)
}

func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-u.com")!
    let (sut,client) = makeSut(url: url)
    sut.load()
    XCTAssertEqual(client.requestedURL,[url])
}

func test_loadTwice_requestDataFromURLTwice() {
    let url = URL(string: "https://a-u.com")!
    let (sut,client) = makeSut(url: url)
    sut.load()
    sut.load()
    XCTAssertEqual(client.requestedURL, [url,url])
}

// MARK:- Helpers
private func makeSut(url: URL =  URL(string: "https://a-u.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
}

private class HTTPClientSpy: HTTPClient {
     var requestedURL = [URL]()
    func get(from url: URL) {
        requestedURL.append(url)
     }
     
 }
