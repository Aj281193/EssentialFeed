//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 26/12/22.
//

import XCTest

class LocalFeedLoader {
    
    
    init(store: FeedStore) {
      
    }
}
class FeedStore {
    var deleteCacheFeedCallCount = 0
}
final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotdeleteCacheUponCreation() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

}
