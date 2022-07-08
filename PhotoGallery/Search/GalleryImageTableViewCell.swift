//
//  GalleryImageTableViewCell.swift
//  PhotoGallery
//
//  Created by Ravali Burugu on 14/02/2022.
//

import UIKit
import Kingfisher

class GalleryImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flickImage: UIImageView!
    
    @IBOutlet weak var imgDesc: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setData(_ photo: Photo) {
        imgDesc.text = photo.title
        
        if let server = photo.server, let id = photo.id, let secret = photo.secret {
            let imageurl  = EndPoint.imagesBaseUrl + server + "/" + id + "_" + secret + ("_w.jpg")
            let url = URL(string: imageurl)
            flickImage.kf.setImage(with:url)
            
        }
    }
}
