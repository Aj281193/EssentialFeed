//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import Foundation
import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        decoratee.load { [weak self] result in
            completion(result.map{ feed in
                self?.cache.save(feed) { _ in }
                return feed
            })
        }
    }
}
