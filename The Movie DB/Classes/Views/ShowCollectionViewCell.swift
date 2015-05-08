//
//  ShowCollectionViewCell.swift
//  The Movie DB
//
//  Created by Jonathan Pacheco on 5/05/15.
//  Copyright (c) 2015 ArandaSoft. All rights reserved.
//

import UIKit
import Alamofire

class ShowCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak private var showImage:       UIImageView!
    @IBOutlet weak private var titleLabel:      UILabel!
    
    private var request: Request?
    
    private var currentShow:    TVShow?
    
    func configureCellWithShow(tvShow: TVShow) {
        titleLabel.text = validateString(tvShow.name)
        showImage.imageWithUrlPath(tvShow.posterPath, request: &request)
    }
    
    override func prepareForReuse() {
        showImage.image = nil
        titleLabel.text = nil
    }
    
}
