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
        let (_,view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view message")
    }
    
    //MARK Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewImageSpy) {
        
        let view = ViewImageSpy()
        let sut = FeedImagePresenter(view: view)
        
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view,file: file,line: line)
        return (sut,view)
    }
    
    private class ViewImageSpy {
        private(set) var messages = [Any]()
    }
}
