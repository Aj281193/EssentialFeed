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

struct FeedLoadingViewModel {
   let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

private class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    
    init(errorView: FeedErrorView, loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) =  makeSUT()
        
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }

    func test_didStartLoadingFeed_displayNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.message, [
            .display(errorMessage: .none),
            .display(isLoading: true)
            ])
    }
    
    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(errorView: view, loadingView: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView {
    
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var message = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            message.insert(.display(isLoading: viewModel.isLoading))
        }
        
    }
}
