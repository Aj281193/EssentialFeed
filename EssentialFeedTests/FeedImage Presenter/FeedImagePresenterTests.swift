//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 09/03/23.
//

import XCTest

private class FeedImagePresenter {
    init(view: Any) {
        
    }
}
final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let view = ViewImageSpy()
        
        _ = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view message")
    }
    
    
    private class ViewImageSpy {
        private(set) var messages = [Any]()
    }
}
