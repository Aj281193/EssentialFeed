//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 11/02/23.
//

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
