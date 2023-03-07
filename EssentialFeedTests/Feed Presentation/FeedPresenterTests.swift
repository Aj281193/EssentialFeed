//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 07/03/23.
//

import XCTest
import EssentialFeed

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

struct FeedLoadingViewModel {
   let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}


protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

private class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedview: FeedView
    
    init(errorView: FeedErrorView, loadingView: FeedLoadingView, feedview: FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedview = feedview
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
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
    
    func test_didFinishLoadingFeed_displaysFeedAndStopLoading() {
        let (sut,view) = makeSUT()
        
        let feed = uniqueImageFeed().models
        sut.didFinishLoadingFeed(with: feed)
    
        XCTAssertEqual(view.message, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(errorView: view, loadingView: view, feedview: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
       
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var message = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            message.insert(.display(isLoading:
                               viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            message.insert(.display(feed: viewModel.feed))
        }
        
        
    }
}
