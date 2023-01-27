//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 29/12/22.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
