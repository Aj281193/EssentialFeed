//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 23/07/23.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValueForAllSupportedLocalizations() {
        let table = "Shared"
        
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValueExist(in: presentationBundle, table)
    }
    
    private class DummyView: ResourceView {
        typealias ResourceViewModel = Any
        
        func display(_ viewModel: Any) { }
    }
}
