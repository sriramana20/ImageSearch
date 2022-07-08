//
//  ViewController.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 14/02/2022.
//

import UIKit
import Combine

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var galleryTableView: UITableView!
    private var bindings = Set<AnyCancellable>()
    var searchController = UISearchController()
    var filteredData = [Photo]()
    
    let viewModel:GalleryViewModelType = GalleryViewModel(repository: GalleryRepository())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModelState()
        
        searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            galleryTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        let apiRequest = ApiRequest(baseUrl: EndPoint.baseUrl, path: "", params: ["method"  : EndPoint.photoMethod,"api_key": EndPoint.apiKey, "text" : "cat", "format" : "json", "nojsoncallback" : "1" ])
        
        self.viewModel.getImages(apiRequest: apiRequest)
        
        // Do any additional setup after loading the view.
    }
    private func bindViewModelState() {
        let cancellable =  viewModel.stateBinding.sink { completion in
            
        } receiveValue: { [weak self] launchState in
            DispatchQueue.main.async {
                self?.updateUI(state: launchState)
            }
        }
        self.bindings.insert(cancellable)
    }
    private func updateUI(state:ViewState) {
        switch state {
        case .none:
            galleryTableView.isHidden = true
        case .loading:
            galleryTableView.isHidden = true
        case .finishedLoading:
            galleryTableView.isHidden = false
            galleryTableView.reloadData()
        case .error(let error):
            galleryTableView.reloadData()
        }
    }
}

extension GalleryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (searchController.isActive) {
            return filteredData.count
        } else {
            return viewModel.imageCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tablecell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as? GalleryImageTableViewCell else { return UITableViewCell() }
        if  (searchController.isActive) {
            tablecell.setData(filteredData[indexPath.row])
        } else {
            tablecell.setData(viewModel.images[indexPath.row])
        }
        return tablecell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let saveAction = UIContextualAction(style: .normal, title: "Save") {
            (action, sourceView, completionHandler) in
            let photo = self.viewModel.images[(indexPath as NSIndexPath).row] as Photo
            self.swipeSaveAction(photo, indexpath: indexPath)
            completionHandler(true)
        }
        
        
        saveAction.backgroundColor = UIColor(red: 255/255.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0)
        let shareAction = UIContextualAction(style: .normal, title: "Share") {
            (action, sourceView, completionHandler) in
            self.swipeShareAction(indexpath: indexPath)
            completionHandler(true)
        }
        
        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [ saveAction, shareAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
        
    }
    
}
extension GalleryViewController {
    
    func swipeSaveAction( _ imageData : Photo, indexpath : IndexPath) {
        let cell = galleryTableView.cellForRow(at: indexpath) as? GalleryImageTableViewCell
        
        guard let inputImage = cell?.flickImage.image else { return }
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: inputImage)
    }
    
    func swipeShareAction(indexpath : IndexPath) {
        let cell = galleryTableView.cellForRow(at: indexpath) as? GalleryImageTableViewCell
        guard let inputImage = cell?.flickImage.image else { return }
        let items = [inputImage]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
}

extension GalleryViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredData.removeAll(keepingCapacity: false)
        let newDdata = viewModel.images.filter { photo in
            if let text = photo.title, let searchTtext = searchController.searchBar.text, text.contains(searchTtext){
                return true
            }
            return false
        }
        filteredData = newDdata
        
        self.galleryTableView.reloadData()
    }
    
}
