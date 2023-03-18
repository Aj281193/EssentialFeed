//
//  SharedTestsHelper.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 31/12/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return  URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
