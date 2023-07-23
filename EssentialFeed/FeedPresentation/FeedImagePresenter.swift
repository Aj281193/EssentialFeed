//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 11/03/23.
//

import Foundation


public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private var imageTransformation: (Data) -> Image?
    
    public init(view: View, imageTransformation: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformation = imageTransformation
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        guard let image = imageTransformation(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
    
    public static func map(_ image: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            description: image.description,
            location: image.location,
            image: nil,
            isLoading: false,
            shouldRetry: false)
    }
}
