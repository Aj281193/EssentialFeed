//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 25/03/23.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion)  {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                   CacheFeed(feed: $0.localFeed, timeStamp: $0.timeStamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = timestamp
                managedCache.feed = ManagedFeedImage.images(feed: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.deleteCache(in: context)
            })
        }
    }
    
}
