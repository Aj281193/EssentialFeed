//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 26/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
 
    func test_title_isLocalized() {
       
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    //MARK Helpers:-
    private  func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let table = "ImageComments"
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
        return value
    }
    
}
