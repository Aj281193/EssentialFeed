//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Ashish Jaiswal on 13/08/23.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine


final class CommentsUIIntegrationTests: FeedUIIntegrationTests {

   func test_commentView_hasTitle() {
        let (sut , _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentTitle)
    }
     
     func test_loadComentsActions_requestCommentFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentCallCount, 0, "Expected no loading request before view is loaded")
  
       
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentCallCount, 1, "Expected a loading request once the view is loaded")
  
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 2, "Expected another loading request once user initiate a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the view is loaded")
  
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the loading completed successfully")
   
   
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user complete with an error")
        
    }
    
    override func test_loadFeedCompletion_renderSuccessFullyLoadedFeed() {
        let image0 = makeImage(description: "any description",location: "any location")
        let image1 = makeImage(description: nil,location: "any location")
        let image2 = makeImage(description: "any description",location: nil)
        let image3 = makeImage(description: nil,location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendring: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendring: [image0])

        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0,image1,image2,image3],at: 1)
        assertThat(sut, isRendring: [image0,image1,image2,image3])
    }
    
    override func test_loadFeedCompletion_renderSuccessFullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0,image1],at: 0)
        assertThat(sut, isRendring: [image0,image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [],at: 1)
        assertThat(sut, isRendring: [])
        
    }
    
    override func test_loadFeedCompletion_doesNotAlterRenderStateOnError() {
        let image0 = makeImage()
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendring: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendring: [image0])
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    override  func test_tapsOnErrorView_hidesErrorMessage() {
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
 
    //Mark:- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
        
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
       return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private class LoaderSpy {
        
        private var requests = [PassthroughSubject<[FeedImage],Error>]()
        
        
        func loadPublisher() -> AnyPublisher<[FeedImage], Swift.Error> {
            let publisher = PassthroughSubject<[FeedImage],Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadCommentCallCount: Int {
            return requests.count
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            requests[index].send(feed)
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
