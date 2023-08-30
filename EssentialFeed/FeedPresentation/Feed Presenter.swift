//
//  File.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 12/03/23.
//

import Foundation

public final class FeedPresenter {
   
    public static var title: String {
         NSLocalizedString("FEED_VIEW_TITLE",
                tableName: "EssentialFeedLocalized",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "")
    }
  
}

