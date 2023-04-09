//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    let decoratee: FeedImageDataLoader
    let imageCache: FeedImageCache
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.imageCache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { imageData in
                self?.imageCache.save(imageData, for: url) { _ in }
                return imageData
            })
        }
        return task
    }
}
