//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 08/02/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedloader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedloader().dispatchOnMainQueue() })
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
      
        presentationAdapter.presenter = FeedPresenter(feedview:
                                                        FeedAdapter(controller: feedController,
                                                                    loader: { imageLoader($0).dispatchOnMainQueue()}),
                                                      loadingView: WeakRefVirtualProxy(feedController), errorView: WeakRefVirtualProxy(feedController))
       
        return feedController
    }
}


private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = FeedPresenter.title
        feedController.delegate = delegate
        
        return feedController
    }
}





