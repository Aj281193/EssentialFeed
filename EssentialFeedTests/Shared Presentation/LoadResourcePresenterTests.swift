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
    
    func test_didStartLoadingResource_displayNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.message, [
            .display(errorMessage: .none),
            .display(isLoading: true)
            ])
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopLoading() {
        let (sut,view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
    
        XCTAssertEqual(view.message, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    
    func test_didFinishLoadingResourceWithError_displaysLocalizedErrorMessageAndStopLoadingFeed() {
        let (sut,view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.message, [.display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
             .display(isLoading: false) ])
    }
        
    func test_didFinishLoadingResourceWithMapperError_displaysLocalizedErrorMessageAndStopLoadingFeed() {
        let (sut,view) = makeSUT { resource in
            throw anyNSError()
        }
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.message, [.display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
             .display(isLoading: false) ])
    }
    
    //MARK Helpers:-
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line)
        -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        
            let sut = LoadResourcePresenter(resourceView: view, loadingView: view, errorView: view, mapper: mapper)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view, file: file,line: line)
        return (sut,view)
    }
    
    private  func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: SUT.self)
        
        let table = "Shared"
        let localizedKey = key
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        
        if value == key {
           XCTFail("Missing localized string for key: \(key) in table \(table)", file: file,line: line)
        }
       return value
    }
    
    private class ViewSpy: ResourceErrorView, ResourceLoadingView, ResourceView {
       typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var message = Set<Message>()
        
        func display(_ viewModel: ResourceErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            message.insert(.display(isLoading:
                               viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            message.insert(.display(resourceViewModel: viewModel))
        }

    }
    
}
