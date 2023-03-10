//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 09/03/23.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLoaction: Bool {
        return location == nil
    }
}

private final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private var imageTransformation: (Data) -> Image?
    
    init(view: View, imageTransformation: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformation = imageTransformation
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        guard let image = imageTransformation(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
final class FeedImagePresenterTests: XCTestCase {

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
