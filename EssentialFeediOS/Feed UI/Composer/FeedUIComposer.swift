//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 08/02/23.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedloader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedloader: feedloader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // [FeedImage] -> Adapt -> [FeedImageCellController]
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
