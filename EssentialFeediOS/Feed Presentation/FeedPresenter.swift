//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 16/02/23.
//

import Foundation
import EssentialFeed


struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    let message: String?
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {

    private let feedview: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(feedview: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedview = feedview
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                     tableName: "Feed",
                     bundle: Bundle(for: FeedPresenter.self),
                     comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "")
    }
    
    func didStartLoadingFeed() {
        errorView.display(FeedErrorViewModel(message: nil))
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
 
}
