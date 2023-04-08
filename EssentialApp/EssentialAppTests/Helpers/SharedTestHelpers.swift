//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 08/04/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "ERROR", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
