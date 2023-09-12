//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 02/04/23.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
  
    private lazy var httpClient: HTTPClient = {
        URLSessionHttpClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var navigationController = UINavigationController(rootViewController:
                                                FeedUIComposer.feedComposedWith(
                                                feedloader: makeRemoteFeedLoaderWithLocalFallback,
                                                imageLoader: makeLocalImageLoaderWithRemoteFallback,
                                                selection: showComments))
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
        } catch {
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
       LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {

        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()

    }


    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndPoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        localFeedLoader.loadPublisher()
            .zip( makeRemoteFeedLoader(after: last))
            .map {  (cachedItems , newItems) in
                return (cachedItems + newItems, newItems.last)
            }.map(makePage)
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after last: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndPoint.get(after: last).url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    
    private func makeRemoteCommentLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
      
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient.getPublisher(url: url)
                    .tryMap(FeedImageMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}

