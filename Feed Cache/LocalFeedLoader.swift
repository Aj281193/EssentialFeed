//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 28/12/22.
//

import Foundation
private final class FeedCachePolicy {
    let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
   func validate(_ timeStamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return currentDate() < maxCacheAge
    }
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    private let cachePolicy: FeedCachePolicy
    
    public init(store: FeedStore,currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: self.currentDate)
    }
}

extension LocalFeedLoader {
    public typealias saveResult = Error?
   
    public func save(_ feed: [FeedImage], completion: @escaping (saveResult) -> Void) {
        store.deleteCacheFeed() { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    private func cache(_ feed: [FeedImage],with completion: @escaping (saveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = FeedLoaderResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timeStamp) where self.cachePolicy.validate(timeStamp):
                completion(.success(feed.toModel()))
            case .found , .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCacheFeed { _ in }
            case let .found(_, timeStamp) where !self.cachePolicy.validate(timeStamp):
                self.store.deleteCacheFeed { _ in }
            case .empty,.found: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
