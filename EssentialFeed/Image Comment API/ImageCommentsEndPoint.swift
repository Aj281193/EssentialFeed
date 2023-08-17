//
//  ImageCommentsEndPoint.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 15/08/23.
//

import Foundation

public enum ImageCommentsEndPoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
