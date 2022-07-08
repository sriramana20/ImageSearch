//
//  GalleryRepository.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 14/02/2022.
//

import Foundation
import Combine

protocol GalleryRepositoryType {
    func getImages(apiRequest:ApiRequestType)->Future<[Photo], ServiceError>
}

class GalleryRepository: GalleryRepositoryType {
    
    let networkManager: Networkable
    
    var cancellables:Set<AnyCancellable?> = Set()
    
    init(networkManager:Networkable = NetworkManager()) {
        self.networkManager = networkManager
    }
    func getImages(apiRequest: ApiRequestType) -> Future<[Photo], ServiceError> {
        return Future { [unowned self] promise in
            
            let apiCallPublisher =   self.networkManager.doApiCall(apiRequest: apiRequest)
            let cancellable = Publishers.Zip(apiCallPublisher, apiCallPublisher).sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    return promise(.failure(error))
                }
                
            } receiveValue: { (data, data2) in
                guard let decodedResponse = try? JSONDecoder().decode(GalleryBaseModel.self, from: data) else {
                    return promise(.failure(ServiceError.parsingError))
                }
                if let photoList = decodedResponse.photos?.photo, photoList.count > 0 {
                    return promise(.success(photoList))
                }
            }
            self.cancellables.insert(cancellable)
        }
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable?.cancel()
        }
    }
}
