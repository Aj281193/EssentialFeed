//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 13/07/23.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doestNotLoadDataFromURL() {
        let (_, client) = makeSut()
        XCTAssertTrue(client.requestedURL.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-u.com")!
        let (sut,client) = makeSut(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURL,[url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-u.com")!
        let (sut,client) = makeSut(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURL, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut,client) = makeSut()
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut,client) = makeSut()

        let samples = [199,150,300,400,500]
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let jsonData = makeItemsJSON([])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn2xxHTTPResponseWithInvalidJson() {
        let (sut,client) = makeSut()
        
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let invalidJson = Data("InvalidJson".utf8)
                client.complete(withStatusCode: code, data: invalidJson, at: index)
            }
        }
    }
    
    func test_deliversNoItemOn2xxHttpResponseWithEmptyJsonList() {
        let (sut,client) = makeSut()

        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: .success([])) {
                let emptyListJson = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyListJson, at: index)
            }
        }
    }
    
    func test_load_deliversItemsOn2xxHttpResponseWithJsonItems() {
        let (sut,client) = makeSut()
        let item1 = makeItem(id: UUID(),
                            imageURL: URL(string: "https://a-url.com")!)
        
        
        let item2 = makeItem(id: UUID(),
                             description: "a desc",
                             location: "a loc",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let items = [item1.model,item2.model]
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: .success(items)) {
                let jsonData = makeItemsJSON([item1.json,item2.json])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultAfterTheInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var captureResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { captureResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    // MARK:- Helpers
    private func makeSut(url: URL =  URL(string: "https://a-u.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)
        return (sut, client)
    }
      
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch(receivedResult,expectedResult) {
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
