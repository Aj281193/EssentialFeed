//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 16/02/23.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
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
       loadingView?.display(isLoading: true)
        feedloader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedview?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
    
}
