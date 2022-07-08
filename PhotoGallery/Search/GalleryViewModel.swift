//
//  GalleryViewModel.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 15/02/2022.
//

import Foundation
import Combine

enum ViewState: Equatable {
    case none
    case loading
    case finishedLoading
    case error(String)
}

protocol GalleryViewModelType {
    var stateBinding: Published<ViewState>.Publisher { get }
    var imageCount:Int { get }
    var images:[Photo] { get }
    func getImages(apiRequest: ApiRequestType)
    func searchImages(keyword: String, apiRequest:ApiRequest)
}

final class GalleryViewModel: GalleryViewModelType {
    
    var stateBinding: Published<ViewState>.Publisher{ $state }
    
    private let repository:GalleryRepositoryType
    private var cancellables:Set<AnyCancellable> = Set()
    
    @Published  var state: ViewState = .none
    
    var images:[Photo] = []
    
    var imageCount: Int {
        return images.count
    }
    
    init(repository:GalleryRepositoryType) {
        self.repository = repository
    }
    
    func getImages(apiRequest: ApiRequestType) {
        
        state = ViewState.loading
        let publisher =   self.repository.getImages(apiRequest: apiRequest)
        
        let cancalable = publisher.sink { [weak self ]completion in
            switch completion {
            case .finished:
                break
            case .failure(_):
                self?.state = ViewState.error("Network Not Availale")
            }
        } receiveValue: { [weak self] images in
            self?.images = images
            self?.state = ViewState.finishedLoading
        }
        self.cancellables.insert(cancalable)
    }
    func searchImages(keyword: String, apiRequest: ApiRequest) {
        if keyword .count > 0 {
            getImages(apiRequest: apiRequest)
        }
    }
    
    
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
}
