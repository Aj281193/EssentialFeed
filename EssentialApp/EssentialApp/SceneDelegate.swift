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
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite"))
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
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Swift.Error> {
        let remoteURL = FeedEndPoint.get().url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map {
                Paginated(items: $0)
            }
            .eraseToAnyPublisher()
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

