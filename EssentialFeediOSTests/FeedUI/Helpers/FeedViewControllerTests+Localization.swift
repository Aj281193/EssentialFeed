//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//
import Foundation
import XCTest
import EssentialFeediOS

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        
        let table = "Feed"
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
           XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
       return value
    }
}
