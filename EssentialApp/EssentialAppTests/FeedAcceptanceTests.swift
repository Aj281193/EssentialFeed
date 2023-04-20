//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 20/04/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomeHasConnectivity() {
     
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numbderOfRenderFeedImageView(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
        
    }
    
    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
       
    }
    
    func test_onLaunch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
      
    }
    
    // MARK:-  Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() { }
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data,HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub(stub: { url in .success(stub(url))})
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
      
        private var feedCache: CacheFeed?
        private var feedImageDataCache: [URL: Data] = [:]
    
        func deleteCacheFeed(completion: @escaping DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            feedCache = CacheFeed(feed: feed, timeStamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
            
        func retrieve(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }
    
    private func response(for url: URL) -> (Data,HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
                ["id": UUID().uuidString,"image":"http://image.com"],
                ["id":UUID().uuidString,"image": "http://image.com"]
     ]])
    }
}
