//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 07/03/23.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {

    func test_title_isLocalized() {
       
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    
    //MARK Helpers:-
    private  func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let table = "EssentialFeedLocalized"
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
        return value
    }
}
