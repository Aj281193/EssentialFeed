//
//  File.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 12/03/23.
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public final class FeedPresenter {
   
    private let feedview: FeedView
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    public init(feedview: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.feedview = feedview
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "EssentialFeedLocalized",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "")
    }
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                     tableName: "Shared",
                     bundle: Bundle(for: FeedPresenter.self),
                     comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}

