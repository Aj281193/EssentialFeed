//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,client) = makeSut()

        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let jsonData = makeItemsJSON([])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn200HTTPResponseWithInvalidJson() {
        let (sut,client) = makeSut()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJson = Data("InvalidJson".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_deliversNoItemOn200HttpResponseWithEmptyJsonList() {
        let (sut,client) = makeSut()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsOn200HttpResponseWithJsonItems() {
        let (sut,client) = makeSut()
        let item1 = makeItem(id: UUID(),
                            imageURL: URL(string: "https://a-url.com")!)
        
        
        let item2 = makeItem(id: UUID(),
                             description: "a desc",
                             location: "a loc",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let items = [item1.model,item2.model]
        expect(sut, toCompleteWithResult: .success(items)) {
            let jsonData = makeItemsJSON([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    // MARK:- Helpers
    private func makeSut(url: URL =  URL(string: "https://a-u.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)
        return (sut, client)
    }
      
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch(receivedResult,expectedResult) {
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected  Result \(expectedResult) got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let item = FeedImage(id: id,
                            description: description,
                            location: location,
                            url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item,json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
}

