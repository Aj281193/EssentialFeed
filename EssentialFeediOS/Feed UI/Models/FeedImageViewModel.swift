//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 11/02/23.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var tasks: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader  = imageLoader
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    var hasLoaction: Bool {
        return location == nil
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryButtonStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryButtonStateChange?(false)
        tasks = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
            self?.handle(result)
        })
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            self.onImageLoad?(image)
        } else {
            self.onShouldRetryButtonStateChange?(true)
        }
        self.onImageLoadingStateChange?(false)
    }
    
    func cancelImageLoad() {
        tasks?.cancel()
        tasks = nil
    }
}
