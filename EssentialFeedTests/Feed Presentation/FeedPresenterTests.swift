//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 07/03/23.
//

import XCTest

private class FeedPresenter {
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }

    private class ViewSpy {
        var message = [Any]()
    }
}
