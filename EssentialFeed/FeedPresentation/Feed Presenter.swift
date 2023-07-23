//
//  File.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 12/03/23.
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public final class FeedPresenter {
   
    public static var title: String {
         NSLocalizedString("FEED_VIEW_TITLE",
                tableName: "EssentialFeedLocalized",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "")
    }
  
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}

