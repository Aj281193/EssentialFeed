//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 21/03/23.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataFromURL_requestImageDataInsertionForURL() {
        let (sut,store) = makeSUT()

        let url = anyURL()
        let data = anyData()

        sut.save(data, for: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, url: url)])
    }

    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut,store) = makeSUT()
        
        expect(sut, toCompletedWith: failed()) {
            let insertionError = anyNSError()
            store.completeInsertion(With: insertionError)
        }
        
    }
    
    func test_saveImageDataFromURL_succedsOnSuccessfulStoreInsertion() {
        let (sut,store) = makeSUT()
        
        expect(sut, toCompletedWith: .success(())) {
            store.completeInsertionSuccessFully()
        }
    }
    
    
    // MARK Helpers:-
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line)  -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy){
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(sut,file: file,line: line)
        trackForMemoryLeak(store, file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompletedWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        action()
        
        
        sut.save(anyData(), for: anyURL()) { receiveResult in
            switch (receiveResult,expectedResult) {
            case (.success,.success): break
            case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),.failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("expected result \(expectedResult) got received result \(receiveResult)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
}
