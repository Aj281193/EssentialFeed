//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 02/01/23.
//

import Foundation

final class FeedCachePolicy {
    private init() {}
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else { return false }
        return date < maxCacheAge
    }
}
