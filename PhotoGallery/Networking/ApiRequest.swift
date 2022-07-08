//
//  ApiRequest.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 14/02/2022.
//

import Foundation

protocol ApiRequestType {
    var baseUrl:String {get}
    var path:String {get}
    var params:[String:String] {get}
}

struct ApiRequest:ApiRequestType {
    var baseUrl: String
    var path: String
    var params: [String : String]
}

enum ServiceError: Error {
    case failedToCreateRequest
    case dataNotFound
    case parsingError
    case networkNotAvailable
    
}

