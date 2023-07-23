//
//  FeedLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 01/07/23.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    private let feedLoader: () -> AnyPublisher<[FeedImage], Swift.Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoader: @escaping() -> AnyPublisher<[FeedImage], Swift.Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader().sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: {[weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        }
    }
}
