//
//  CoreDataFeedStore+FeedImageDataModel.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 24/03/23.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                guard let image = try? ManagedFeedImage.first(with: url, in: context)  else { return }
                
                image.data = data
                try? context.save()
            })
        }
    }
    
    public func completeRetrieval(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                return try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
}
