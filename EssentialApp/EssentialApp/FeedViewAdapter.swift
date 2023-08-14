//
//  FeedAdapter.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 01/07/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    
    init(controller: ListViewController,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = LoadResourcePresentationAdapter<Data,
                                WeakRefVirtualProxy<FeedImageCellController>> { [imageLoader] in
                                imageLoader(model.url)
            }
        
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter, selection: { [selection] in
                    selection(model)
                })
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    return image
                })
        
            return CellController(id: model, view)
        })
    }
}

private struct InvalidImageData: Error { }
