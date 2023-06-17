//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/03/23.
//

import Foundation

public struct FeedImageViewModel<Image> {
   public let description: String?
   public let location: String?
   public let image: Image?
   public let isLoading: Bool
   public let shouldRetry: Bool
        
    public var hasLoaction: Bool {
        return location == nil
    }
}
