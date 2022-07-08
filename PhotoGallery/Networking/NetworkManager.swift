//
//  NetworkManager.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 14/02/2022.
//

import Foundation

import Combine

protocol Networkable {
    func doApiCall(apiRequest:ApiRequestType)-> Future<Data, ServiceError>
}

class NetworkManager: Networkable {
    let session:URLSession
    init(session:URLSession = URLSession.shared) {
        self.session = session
    }
    
    func doApiCall(apiRequest: ApiRequestType) -> Future<Data, ServiceError> {
        return Future { [weak self] promise in
            
            guard Rechability.shared.isInternetAvailable() == true
            else {
                return                 promise(.failure(ServiceError.networkNotAvailable))
            }
            
            guard let request = URLRequest.getURLRequest(for: apiRequest) else {
                promise(.failure(ServiceError.failedToCreateRequest))
                return
            }
            self?.session.dataTask(with: request, completionHandler: { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    return promise(.failure(ServiceError.dataNotFound))
                }
                guard let _data = data, error == nil else {
                    return promise(.failure(ServiceError.dataNotFound))
                }
                return promise(.success(_data))
            }).resume()
        }
    }
}

extension URLRequest {
    static func getURLRequest(for apiRequest:ApiRequestType)-> URLRequest? {
        if let url = URL(string:apiRequest.baseUrl.appending(apiRequest.path)),
           var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false){
            let queryItems = apiRequest.params.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            urlComponents.queryItems = queryItems
            let urlRequest = URLRequest(url: urlComponents.url!)
            return urlRequest
        } else {
            return nil
        }
    }
}
