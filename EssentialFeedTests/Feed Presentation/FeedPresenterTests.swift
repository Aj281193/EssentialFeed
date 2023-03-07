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
        let (_, view) =  makeSUT()
        
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }

    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(view: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy {
        var message = [Any]()
    }
}
