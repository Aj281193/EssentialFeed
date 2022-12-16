//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import Foundation

enum FeedLoaderItems {
    case success([FeedItems])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping([FeedLoaderItems]) -> Void)
}
