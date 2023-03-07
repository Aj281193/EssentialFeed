//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 07/03/23.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}
protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

private class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) =  makeSUT()
        
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }

    func test_didStartLoadingFeed_displayNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.message, [.display(errorMessage: .none)])
    }
    
    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy: FeedErrorView {
       
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var message = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.append(.display(errorMessage: viewModel.message))
        }
    }
}
