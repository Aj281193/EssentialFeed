//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 09/03/23.
//

import XCTest
import EssentialFeed


final class FeedImagePresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter<ViewImageSpy, AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
    
    func test_init_doesNotSendMessageToView() {
        let (_,view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view message")
    }
    
    func test_didStartLoadingImageData_displayLoadingImage() {
        let (sut,view) = makeSUT()
        
        let image = uniqueImage()
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displayRetryonFailedImageTransformation() {
        let (sut,view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
        
    }
    
    func test_didFinishLoadingImageData_displayImageOnSuccessfullTransformation() {
        
        
        let image = uniqueImage()
        
        let transformationData = AnyImage()
        
        let (sut,view) = makeSUT(imageTransformer: { _ in transformationData })
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformationData)
    }
    
    func test_didFinishLoadingImageDataWithError_displayRetry() {
        let (sut,view) = makeSUT()
        
        let image = uniqueImage()
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
        
    }
    
    //MARK Helpers
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewImageSpy, AnyImage>, view: ViewImageSpy) {
        
        let view = ViewImageSpy()
        let sut = FeedImagePresenter(
            view: view,
            imageTransformation: imageTransformer)
        
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(view,file: file,line: line)
        return (sut,view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewImageSpy: FeedImageView {

        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
