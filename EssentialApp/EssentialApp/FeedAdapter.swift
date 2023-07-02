//
//  FeedAdapter.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 01/07/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformation: UIImage.init)
            return view
        })
    }
}
