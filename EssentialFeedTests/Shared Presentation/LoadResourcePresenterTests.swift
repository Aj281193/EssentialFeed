//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 22/07/23.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {

    
    func test_init_doesNotSendMessageToView() {
        let (_, view) =  makeSUT()
        
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
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
    
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopLoadingFeed() {
        let (sut,view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.message, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
             .display(isLoading: false) ])
    }
        
    
    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = LoadResourcePresenter(feedview: view, loadingView: view, errorView: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private  func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: LoadResourcePresenter.self)
        
        let table = "EssentialFeedLocalized"
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
           XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
       return value
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
