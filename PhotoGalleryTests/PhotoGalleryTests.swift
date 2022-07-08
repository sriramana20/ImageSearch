//
//  PhotoGalleryTests.swift
//  PhotoGalleryTests
//
//  Created by Ravali Burugu on 16/02/2022.
//

import XCTest
@testable import PhotoGallery

class PhotoGalleryTests: XCTestCase {
    
    var viewModel:GalleryViewModel!
    var respository:GalleryRepository!
    var networkManager:MockNetworkManager!
  
    
    override func setUpWithError() throws {
        
        networkManager = MockNetworkManager()
        respository = GalleryRepository(networkManager: networkManager)
        viewModel = GalleryViewModel(repository: respository)
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testSearchGallery_success() {
        
        let galleryApiRquest = ApiRequest(baseUrl: EndPoint.baseUrl, path: "GalleryData", params: [:])
               
        viewModel.getImages(apiRequest: galleryApiRquest)
        
        XCTAssertEqual(viewModel.imageCount, 100)
        XCTAssertEqual(viewModel.images.count, 100)
    
    }
}

