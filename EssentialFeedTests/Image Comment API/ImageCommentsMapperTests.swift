//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ashish Jaiswal on 13/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {
    
  
    func test_map_throwErrorOnNon2xxHTTPResponse() throws {
        let jsonData = makeItemsJSON([])
  
        let samples = [199,150,300,400,500]
        try samples.forEach {code  in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(jsonData, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwErrorOn2xxHTTPResponseWithInvalidJson() throws {
        let invalidJson = Data("InvalidJson".utf8)
        let samples = [200,201,250,280,299]
        
        try samples.forEach {  code  in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJson, HTTPURLResponse(statusCode: code))
            )

        }
    }
    
    func test_map_deliversNoItemOn2xxHttpResponseWithEmptyJsonList() throws {
      
        let emptyListJson = makeItemsJSON([])
        let samples = [200,201,250,280,299]
        
          try samples.forEach {  code  in
            let result = try ImageCommentsMapper.map(emptyListJson, HTTPURLResponse(statusCode: code))
             XCTAssertEqual([], result)
            }
    }
    
    func test_map_deliversItemsOn2xxHttpResponseWithJsonItems() throws {
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
        
        let jsonData = makeItemsJSON([item1.json,item2.json])
        let samples = [200,201,250,280,299]
        
        try samples.forEach {code  in
            let result = try ImageCommentsMapper.map(jsonData, HTTPURLResponse(statusCode: code))
             XCTAssertEqual([item1.model,item2.model], result)
        }
    }
    
    // MARK:- Helpers
 
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
}

