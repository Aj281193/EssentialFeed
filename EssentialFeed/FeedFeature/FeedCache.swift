//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 09/04/23.
//

import Foundation

public protocol FeedCache {
    typealias saveResult = Result<Void,Error>
   
    func save(_ feed: [FeedImage], completion: @escaping (saveResult) -> Void)
}
