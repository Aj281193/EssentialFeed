//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public final class LocalFeedImageDataLoader {
        
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try  store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public enum LoadError: Swift.Error {
     case failed
     case notFound
    }
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataFromURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
    }
}
