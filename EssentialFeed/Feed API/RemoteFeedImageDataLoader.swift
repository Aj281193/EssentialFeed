//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/03/23.
//

import Foundation
import EssentialFeed

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) ->Void)?
        
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func completed(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFutherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
       
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.completed(with: result.mapError { _ in Error.connectivity}.flatMap { (data, response) in
                let isValidResponse = response.statusCode == 200 && !data.isEmpty
                
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }
        return task
    }
}
