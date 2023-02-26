//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 16/02/23.
//

import Foundation
import EssentialFeed


protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {

    private let feedview: FeedView
    private let loadingView: FeedLoadingView
    
    init(feedview: FeedView, loadingView: FeedLoadingView) {
        self.feedview = feedview
        self.loadingView = loadingView
    }
    
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
 
}
