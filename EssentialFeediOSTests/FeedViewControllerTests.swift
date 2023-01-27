//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ashish Jaiswal on 27/01/23.
//

import XCTest

class FeedViewController {
    var loader: FeedViewControllerTests.LoaderSpy
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    //Mark:- Helpers
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
