//
//  FeedEndPoint.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 17/08/23.
//

import Foundation

public enum FeedEndPoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
