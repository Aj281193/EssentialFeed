//
//  hello.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 02/07/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomeHasConnectivity() {
        
        let feed = launch(httpClient: .online(response),store: .empty)

        XCTAssertEqual(feed.numbderOfRenderFeedImageView(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0),makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
        
    }

    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response),store: sharedStore)
        onlineFeed.simulatedFeedImageViewVisible(at: 0)
        onlineFeed.simulatedFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline,store: sharedStore)
        XCTAssertEqual(offlineFeed.numbderOfRenderFeedImageView(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
        
    }
    
    func test_onLaunch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numbderOfRenderFeedImageView(), 0)
    }
    
    //MARK: - Helpers
    
    private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController {
        
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    func test_onEnteringBackground_deleteExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache,"Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache,"Expected to keep non-expired cache")
    }
    
    private func  enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
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
        
        func post(_ data: Data, to url: URL, completion: @escaping (HTTPClient.Result) -> Void) {}
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: {_ in .failure(NSError(domain: "offline", code: 0))})
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url))}
        }
        
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        
        var feedCache: CacheFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        init(feedCache: CacheFeed? = nil) {
            self.feedCache = feedCache
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        func completeRetrieval(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
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
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
        
        static var withExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheFeed(feed: [], timeStamp: Date.distantPast))
        }
        
        static var withNonExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CacheFeed(feed: [], timeStamp: Date()))
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