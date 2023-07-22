//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 22/07/23.
//

import Foundation

public final class LoadResourcePresenter {
    private let feedview: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public init(feedview: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedview = feedview
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                     tableName: "EssentialFeedLocalized",
                     bundle: Bundle(for: FeedPresenter.self),
                     comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
