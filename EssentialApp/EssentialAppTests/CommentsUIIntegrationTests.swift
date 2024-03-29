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


final class CommentsUIIntegrationTests: XCTestCase {

   func test_commentView_hasTitle() {
        let (sut , _) = makeSUT()
        sut.simulateAppearance()   
        
        XCTAssertEqual(sut.title, commentTitle)
    }
     
     func test_loadComentsActions_requestCommentFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentCallCount, 0, "Expected no loading request before view is loaded")
  
       
        sut.simulateAppearance()   
        XCTAssertEqual(loader.loadCommentCallCount, 1, "Expected a loading request once the view is loaded")
  
         sut.simulateUserInitiatedReload()
         XCTAssertEqual(loader.loadCommentCallCount, 1, "Expected no request until previous complete")
        
        loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 2, "Expected another loading request once user initiate a load")
        
        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComment() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the view is loaded")
  
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the loading completed successfully")
   
   
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected a loading indicator once the user initiates a reload")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user complete with an error")
        
    }
    
    func test_loadCommentsCompletion_renderSuccessFullyLoadedComments() {
        let comment0 = makeComments(message: "a message",username: "a username")
        let comment1 = makeComments(message: "another message",username: "another username")
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()   
        assertThat(sut, isRendring: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendring: [comment0])

        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0,comment1],at: 1)
        assertThat(sut, isRendring: [comment0,comment1])
    }
    
     func test_loadCommentsCompletion_renderSuccessFullyLoadedEmptyCommentsAfterNonEmptyComment() {
        let comment = makeComments()
        
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()   
        
        loader.completeCommentsLoading(with: [comment],at: 0)
        assertThat(sut, isRendring: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [],at: 1)
        assertThat(sut, isRendring: [ImageComment]())
        
    }
    
     func test_loadCommentsCompletion_doesNotAlterRenderStateOnError() {
        let comment = makeComments()
        let (sut,loader) = makeSUT()
        
        sut.simulateAppearance()   
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendring: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendring: [comment])
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()   
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()   
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_tapsOnErrorView_hidesErrorMessage() {
        let (sut,loader) = makeSUT()
        
        sut.simulateAppearance()   
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
 
    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?
        
        autoreleasepool {
             sut = CommentsUIComposer.commentsComposedWith {
                PassthroughSubject<[ImageComment], Error>().handleEvents(receiveCancel:  {
                    cancelCallCount += 1
                }).eraseToAnyPublisher()
            }
            
            sut?.simulateAppearance()
        }
       
        weak var weakRef = sut
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        
        XCTAssertNil(weakRef)
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    //Mark:- Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
        
    private func makeComments(message: String = "any message", username: String = "any username") -> ImageComment {
       return ImageComment(id: UUID(), message: message, createdAt: Date(), userName: username)
    }
    
    private func assertThat(_ sut: ListViewController, isRendring comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count , "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message ,"message at \(index)",file: file,line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date ,"date at \(index)",file: file,line: line)
            
            XCTAssertEqual(sut.commentUsername(at: index), comment.username ,"username at \(index)",file: file,line: line)
        }
    }
    
    private class LoaderSpy {
        
        private var requests = [PassthroughSubject<[ImageComment],Error>]()
        
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Swift.Error> {
            let publisher = PassthroughSubject<[ImageComment],Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        var loadCommentCallCount: Int {
            return requests.count
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
            requests[index].send(completion: .finished)
        }
    }
}
