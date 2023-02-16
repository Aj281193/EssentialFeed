//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 11/02/23.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var tasks: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var imageTransformation: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformation: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader  = imageLoader
        self.imageTransformation = imageTransformation
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
    
    var onImageLoad: Observer<Image>?
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
        if let image = (try? result.get()).flatMap(imageTransformation) {
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
