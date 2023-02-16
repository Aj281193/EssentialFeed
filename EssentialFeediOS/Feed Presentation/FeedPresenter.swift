//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 16/02/23.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
   let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedloader: FeedLoader
    
    init(feedloader: FeedLoader) {
        self.feedloader = feedloader
    }
    
    var feedview: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
       loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedloader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedview?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
    
}
