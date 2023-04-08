//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 08/04/23.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "ERROR", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
