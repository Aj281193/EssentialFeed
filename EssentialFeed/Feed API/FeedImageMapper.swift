//
//  FeedImageMapper.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 29/07/23.
//

import Foundation

public final class FeedImageMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK , !data.isEmpty else {
            throw Error.invalidData
        }
        return data
    }
}

