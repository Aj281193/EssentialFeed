//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 07/03/23.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {


    func test_init_doesNotSendMessageToView() {
        let (_, view) =  makeSUT()
        
        XCTAssertTrue(view.message.isEmpty, "Expected no view message")
    }

    func test_title_isLocalized() {
       
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
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
    
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopLoadingFeed() {
        let (sut,view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.message, [.display(errorMessage: localized("GENERIC_CONNECTION_ERROR", table: "Shared")),
             .display(isLoading: false) ])
    }
        
    
    //MARK Helpers:-
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line)  -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(feedview: view, loadingView: view, errorView: view)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private  func localized(_ key: String, table: String = "EssentialFeedLocalized", file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
           XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
       return value
    }
    
    private class ViewSpy: FeedErrorView, ResourceLoadingView, FeedView {
       
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var message = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            message.insert(.display(isLoading:
                               viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            message.insert(.display(feed: viewModel.feed))
        }

    }
}
