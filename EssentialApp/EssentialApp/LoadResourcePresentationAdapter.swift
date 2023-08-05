//
//  FeedLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Ashish Jaiswal on 01/07/23.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    private let loader: () -> AnyPublisher<Resource, Swift.Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping() -> AnyPublisher<Resource, Swift.Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader().sink { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: {[weak self] resource in
            self?.presenter?.didFinishLoading(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
      loadResource()
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
    
    
}