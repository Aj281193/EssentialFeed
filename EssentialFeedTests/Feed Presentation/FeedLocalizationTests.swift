//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/02/23.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValueForAllSupportedLocalizations() {
        let table = "EssentialFeedLocalized"
        let bundle = Bundle(for: FeedPresenter.self)
       
        assertLocalizedKeyAndValueExist(in: bundle, table)
    }
    
}
