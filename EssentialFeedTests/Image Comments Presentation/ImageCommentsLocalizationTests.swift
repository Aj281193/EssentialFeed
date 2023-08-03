//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 26/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValueForAllSupportedLocalizations() {
        let table = "ImageComments"
        
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValueExist(in: presentationBundle, table)
        
    }
}
