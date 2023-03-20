//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
        
        private final class Task: FeedImageDataLoaderTask {
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
    
    public enum Error: Swift.Error {
     case failed
     case notFound
    }
    
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataFromURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError{_ in Error.failed}.flatMap{ data in data.map { .success($0)} ?? .failure(Error.notFound)}
                )
        }
        return task
    }
}
