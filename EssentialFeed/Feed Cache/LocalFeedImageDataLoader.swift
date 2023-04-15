//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public final class LocalFeedImageDataLoader {
        
        private final class loadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        public init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func  preventFurtherCompletion() {
            completion = nil
        }
    
    }
    
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL,completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in
                SaveError.failed
            })
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public typealias loadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Swift.Error {
     case failed
     case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (loadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = loadImageDataTask(completion)
        store.completeRetrieval(dataFromURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError{ _ in LoadError.failed}.flatMap{ data in data.map { .success($0)} ?? .failure(LoadError.notFound) }
                )
        }
        return task
    }
}
