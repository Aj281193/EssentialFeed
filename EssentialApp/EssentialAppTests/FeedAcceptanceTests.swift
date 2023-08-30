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
        XCTAssertEqual(feed.renderedFeedImageData(at: 0),makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        
    }

    func test_onLaunch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response),store: sharedStore)
        onlineFeed.simulatedFeedImageViewVisible(at: 0)
        onlineFeed.simulatedFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline,store: sharedStore)
        XCTAssertEqual(offlineFeed.numbderOfRenderFeedImageView(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
        
    }
    
    func test_onLaunch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numbderOfRenderFeedImageView(), 0)
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
    
    func test_onFeedImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()
        
        XCTAssertEqual(comments.numberOfRenderComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
    
    
    //MARK: - Helpers
    
    private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> ListViewController {
        
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        feed.simulateOnTapFeedImage(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = feed.navigationController
        return nav?.topViewController as! ListViewController
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
        switch url.path {
        case "/image-0":
            return makeImageData0()
        case  "/image-1":
            return makeImageData1()
        case "/essential-feed/v1/feed":
            return makeFeedData()
        case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
            return makeCommentsData()
        default:
            return Data()
        }
    }
    
    private func makeImageData0() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImageData1() -> Data {
        return UIImage.make(withColor: .green).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
          "items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-0"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-1"]
         ]])
    }
    
    private func makeCommentsData() -> Data {
           return try! JSONSerialization.data(withJSONObject: ["items": [
               [
                   "id": UUID().uuidString,
                   "message": makeCommentMessage(),
                   "created_at": "2020-05-20T11:24:59+0000",
                   "author": [
                       "username": "a username"
                   ]
               ] as [String : Any]
           ]])
       }
   
    private func makeCommentMessage() -> String {
        "a message"
    }
}
