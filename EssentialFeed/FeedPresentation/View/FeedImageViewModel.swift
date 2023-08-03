//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/03/23.
//

import Foundation

public struct FeedImageViewModel {
   public let description: String?
   public let location: String?
 
    
    public var hasLoaction: Bool {
        return location == nil
    }
}
