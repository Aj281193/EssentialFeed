//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 13/07/23.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
  
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
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a userName")
        
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another userName")
        
        let items = [item1.model,item2.model]
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index, code  in
            expect(sut, toCompleteWithResult: .success(items)) {
                let jsonData = makeItemsJSON([item1.json,item2.json])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
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
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, ISO8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        
        let item = ImageComment(id: id,
                                message: message,
                                createdAt: createdAt.date,
                                userName: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.ISO8601String,
            "author": [
               "username": username
            ]
        ].compactMapValues { $0 }
        
        return (item,json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
   
}
