//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 17/12/22.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {

    func test_map_throwErrorOnNon200HTTPResponse() throws {
        let jsonData = makeItemsJSON([])
        let samples = [199,201,300,400,500]
        
        try samples.forEach {  code  in
    
            XCTAssertThrowsError(
                try FeedItemMapper.map(jsonData,from: HTTPURLResponse(statusCode: code))
            )
           
        }
    }
    
    func test_map_throwErrorOn200HTTPResponseWithInvalidJson() {
        let invalidJson = Data("InvalidJson".utf8)
    
        XCTAssertThrowsError(
            try FeedItemMapper.map(invalidJson,from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemOn200HttpResponseWithEmptyJsonList() throws {
        let emptyListJson = makeItemsJSON([])
    
        let result = try FeedItemMapper.map(emptyListJson,from: HTTPURLResponse(statusCode: 200))
       
        XCTAssertEqual([], result)
    }
    
    func test_map_deliversItemsOn200HttpResponseWithJsonItems() throws {
        
        let item1 = makeItem(id: UUID(),
                            imageURL: URL(string: "https://a-url.com")!)
        
        
        let item2 = makeItem(id: UUID(),
                             description: "a desc",
                             location: "a loc",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let jsonData = makeItemsJSON([item1.json,item2.json])
        
        let result = try FeedItemMapper.map(jsonData,from: HTTPURLResponse(statusCode: 200))
       
        XCTAssertEqual(result, [item1.model,item2.model])
    }
    
    // MARK:- Helpers
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
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
}
